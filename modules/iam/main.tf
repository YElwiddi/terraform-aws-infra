resource "aws_iam_role" "ec2_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  count      = var.enable_cloudwatch ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy" "s3_read" {
  count = var.enable_s3_read ? 1 : 0
  name  = "${var.environment}-ec2-s3-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = var.s3_bucket_arns
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  count      = var.enable_s3_read ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_read[0].arn
}

resource "aws_iam_policy" "custom" {
  count  = var.custom_policy_json != "" ? 1 : 0
  name   = "${var.environment}-ec2-custom-policy"
  policy = var.custom_policy_json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "custom" {
  count      = var.custom_policy_json != "" ? 1 : 0
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.custom[0].arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = var.tags
}

resource "aws_iam_role" "app_role" {
  count = var.create_app_role ? 1 : 0
  name  = "${var.environment}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.environment}-app-role"
  })
}

resource "aws_iam_instance_profile" "app_profile" {
  count = var.create_app_role ? 1 : 0
  name  = "${var.environment}-app-profile"
  role  = aws_iam_role.app_role[0].name

  tags = var.tags
}

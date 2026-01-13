data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "main" {
  count      = var.public_key != "" ? 1 : 0
  key_name   = "${var.environment}-key"
  public_key = var.public_key

  tags = var.tags
}

resource "aws_instance" "main" {
  count = var.instance_count

  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.instance_profile_name
  key_name               = var.public_key != "" ? aws_key_pair.main[0].key_name : var.key_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    encrypted             = var.encrypt_root_volume
    delete_on_termination = true
  }

  dynamic "ebs_block_device" {
    for_each = var.additional_ebs_volumes
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = ebs_block_device.value.volume_size
      volume_type           = ebs_block_device.value.volume_type
      encrypted             = ebs_block_device.value.encrypted
      delete_on_termination = ebs_block_device.value.delete_on_termination
    }
  }

  user_data = var.user_data

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring = var.enable_detailed_monitoring

  tags = merge(var.tags, {
    Name = var.instance_count > 1 ? "${var.environment}-${var.instance_name}-${count.index + 1}" : "${var.environment}-${var.instance_name}"
  })

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "main" {
  count    = var.associate_elastic_ip ? var.instance_count : 0
  instance = aws_instance.main[count.index].id
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = var.instance_count > 1 ? "${var.environment}-${var.instance_name}-eip-${count.index + 1}" : "${var.environment}-${var.instance_name}-eip"
  })
}

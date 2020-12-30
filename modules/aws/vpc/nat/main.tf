
locals {
  nat_ips     = split(",", var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id))
  vpc_sg_ids  = concat(var.create_sg ? aws_security_group.nat_sg.*.id : [], var.security_groups)
  nat_profile = var.create && var.create_instance_profile ? aws_iam_instance_profile.nat_profile[0].id : var.instance_profile
}

data "aws_caller_identity" "current" {}

resource "aws_eip" "nat" {

  count = var.create && var.reuse_nat_ips == false ? var.nat_count : 0

  vpc = true

  tags = merge(
    { "Name" = format("%s-nat-eip-%s", var.name, element(var.azs, count.index)) },
    var.tags
  )
}

resource "aws_nat_gateway" "nat" {
  count = var.create && var.nat_type == "gateway" ? var.nat_count : 0

  allocation_id = element(local.nat_ips, count.index)
  subnet_id     = element(var.subnet_id, count.index)

  tags = merge(
    { "Name" = format("%s-%s", var.name, element(var.azs, count.index)) },
    var.tags
  )
}

resource "aws_iam_instance_profile" "nat_profile" {
  count = var.create && var.create_instance_profile && var.nat_type == "instance" ? 1 : 0

  name = "${var.name}-nat-profile"
  role = aws_iam_role.nat_role[0].name
}

data "aws_iam_policy_document" "nat_assume_policy" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.id}:root"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "nat_route_policy" {
  statement {
    sid = 1
    actions = [
      "ec2:ReplaceRoute",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:DescribeRouteTables",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstanceAttribute"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

resource "aws_iam_role" "nat_role" {
  count = var.create && var.create_instance_profile && var.nat_type == "instance" ? 1 : 0

  name               = "${var.name}-nat_ha_role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.nat_assume_policy.json
}

resource "aws_iam_role_policy" "nat_route_policy" {
  count = var.create && var.create_instance_profile && var.nat_type == "instance" ? 1 : 0

  name   = "nat_route_policy"
  role   = aws_iam_role.nat_role[0].id
  policy = data.aws_iam_policy_document.nat_route_policy.json
}

resource "aws_iam_role_policy_attachment" "nat_ssm_policy" {
  count = var.create && var.create_instance_profile && var.nat_type == "instance" ? 1 : 0

  role       = aws_iam_role.nat_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_ami" "nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "nat" {

  count = var.create && var.nat_type == "instance" ? var.nat_count : 0

  ami                  = data.aws_ami.nat.id
  instance_type        = var.instance_type
  source_dest_check    = false
  iam_instance_profile = local.nat_profile
  key_name             = var.key_name
  subnet_id            = var.subnet_id[count.index]
  user_data            = file("${path.module}/scripts/nat-simple.sh")

  vpc_security_group_ids = local.vpc_sg_ids

  tags = merge(
    { "Name" = format("%s-nat-%s", var.name, element(var.azs, count.index))
      "role" = "nat"
    },
    var.tags,
  )

  depends_on = [aws_security_group.nat_sg]
}

resource "aws_eip_association" "nat_eip_assoc" {
  count = var.create && var.nat_type == "instance" ? var.nat_count : 0

  instance_id   = aws_instance.nat[count.index].id
  allocation_id = element(local.nat_ips, count.index)
}

resource "aws_security_group" "nat_sg" {
  count = var.create && var.create_sg && var.nat_type == "instance" ? 1 : 0

  name        = format("%s-nat-sg", var.name)
  description = "Security group for the NAT instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "Allow SSH access"
    cidr_blocks = var.ingress_cidr_blocks
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    description = "Allow inbound requests from vpc"
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    description = "Allow inbound requests from vpc"
    cidr_blocks = var.cidr_blocks
  }

  #egress {
  #  from_port   = 0
  #  to_port     = 0
  #  protocol    = "-1"
  #  description = "Allow egress for all ports from anywhere"
  #  cidr_blocks = ["0.0.0.0/0"]
  #}

  egress {
    from_port   = 0
    to_port     = 80
    protocol    = "tcp"
    description = "Allow egress for HTTP port from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 443
    protocol    = "tcp"
    description = "Allow egress for HTTPS port from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = format("%s-nat-sg", var.name)
    },
  var.tags)
}

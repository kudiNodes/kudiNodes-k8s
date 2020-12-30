locals {

    create_public_subnet = length(var.public_subnet_cidr_block) > 0
    create_igw = var.create_vpc && local.create_public_subnet

    create_public_rt = var.create_vpc && length(var.public_subnet_cidr_block)>0
    create_private_rt = var.create_vpc && length(var.private_subnet_cidr_block)>0

    nat_count = var.single_nat ? 1 : length(var.public_subnet_cidr_block)
    domain_name = "${var.name}.${var.domain_name}"

    max_subnet_length = max(
        length(var.private_subnet_cidr_block),
        length(var.database_subnet_cidr_block)
    )

    vpc_id = element(
        concat(
            aws_vpc_ipv4_cidr_block_association.main.*.vpc_id,
            aws_vpc.main.*.id,
            [""],
        ),
        0
    )
}

data "aws_region" "current" {}

resource "aws_vpc" "main" {
    count = var.create_vpc ? 1 : 0

    cidr_block = var.cidr_block
    instance_tenancy = "default"
    enable_dns_hostnames = var.enable_dns_hostnames
    enable_dns_support = var.enable_dns_support
    enable_classiclink = false
    enable_classiclink_dns_support = false
    assign_generated_ipv6_cidr_block = var.enable_ipv6

    tags = merge(
        {"Name" = format("%s-vpc", var.name)},
        var.tags
    )
}

resource "aws_vpc_ipv4_cidr_block_association" "main" {
    count = var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0
    vpc_id = aws_vpc.main[0].id
    cidr_block = element(var.secondary_cidr_blocks, count.index)
} 

resource "aws_vpc_dhcp_options" "main" {
    count = var.create_vpc && var.enable_dhcp_options ? 1 : 0
    domain_name = local.domain_name

    tags = merge(
        {"Name" = format("%s-dhcp-opt", var.name)},
        var.tags
    )
}

resource "aws_vpc_dhcp_options_association" "main" {
    count = var.create_vpc && var.enable_dhcp_options ? 1 : 0
    vpc_id = local.vpc_id
    dhcp_options_id = aws_vpc_dhcp_options.main[0].id
}

resource "aws_route53_zone" "private" {
    count = var.create_vpc && var.enable_dhcp_options ? 1 : 0
    name = local.domain_name
    vpc {
        vpc_id = local.vpc_id
    }
}

resource "aws_internet_gateway" "main" {
    count = local.create_igw ? 1 : 0
    vpc_id = local.vpc_id

    tags = merge(
        {"Name" = format("%s-igw", var.name)}
    )
}

resource "aws_route_table" "public" {
    count = local.create_public_rt ? 1 : 0

    vpc_id = local.vpc_id

    tags = merge(
      {"Name" = "${var.name}-public-rt"},
      var.tags
    )
}

resource "aws_route_table" "private" {  
    count = local.create_private_rt && var.enable_nat ? local.nat_count : 0

    vpc_id = local.vpc_id

    tags = merge(
      {"Name" = var.single_nat ? "${var.name}-private-rt" : format("%s-private-rt-%s", var.name, var.azs[count.index])},
      var.tags
    )

    lifecycle {
        ignore_changes = [propagating_vgws]
    }
}

resource "aws_route_table_association" "public" {
    count = local.create_public_rt ? length(module.public_subnet.id) : 0

    subnet_id      = module.public_subnet.id[count.index]
    route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
    count = local.create_private_rt && var.enable_nat ? local.nat_count : 0

    subnet_id      = module.private_subnet.id[count.index]
    route_table_id = var.single_nat ? aws_route_table.private[0].id : aws_route_table.private[count.index].id    
}

resource "aws_route" "igw_ipv4" {
    count = var.create_vpc && local.create_igw && length(module.public_subnet.id)>0 ? 1 : 0

    route_table_id         = aws_route_table.public[0].id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main[0].id

    timeouts {
        create = "5m"
    }
}

resource "aws_route" "igw_ipv6" {
    count = var.create_vpc && var.enable_ipv6 && local.create_igw && length(module.public_subnet.id)>0 ? 1 : 0

    route_table_id         = aws_route_table.public[0].id
    destination_ipv6_cidr_block = "::/0"
    gateway_id             = aws_internet_gateway.main[0].id
}

resource "aws_route" "nat_gateway" {
    count = var.create_vpc && var.enable_nat && var.nat_type == "gateway" ? local.nat_count : 0

    route_table_id = element(aws_route_table.private.*.id, count.index)
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(module.nat.gateway_id, count.index)

    timeouts {
        create = "5m"
    }
}

resource "aws_route" "nat_instance" {
    count = var.create_vpc && var.enable_nat && var.nat_type == "instance" ? local.nat_count : 0

    route_table_id = element(aws_route_table.private.*.id, count.index)
    destination_cidr_block = "0.0.0.0/0"
    instance_id = element(module.nat.instance_id, count.index)

    timeouts {
        create = "5m"
    }
}

module "public_subnet" {
    source = "./subnet"

    create = var.create_vpc && length(var.public_subnet_cidr_block)>0
    name = var.name
    vpc_id = local.vpc_id
    azs = var.azs

    subnet_type = "public"

    map_public_ip_on_launch = var.map_public_ip_on_launch
    enable_ipv6 = var.enable_ipv6 && length(var.public_subnet_ipv6_prefix)>0

    cidr_block = var.public_subnet_cidr_block
    vpc_ipv6_cidr_block = aws_vpc.main[0].ipv6_cidr_block
    ipv6_prefix = var.public_subnet_ipv6_prefix

    tags = merge(var.tags, var.public_subnet_tags)    
}

module "private_subnet" {
    source = "./subnet"

    create = var.create_vpc && length(var.private_subnet_cidr_block)>0
    name   = var.name
    vpc_id = local.vpc_id
    azs    = var.azs

    subnet_type = "private"

    map_public_ip_on_launch = false
    enable_ipv6 = var.enable_ipv6 && length(var.private_subnet_ipv6_prefix)>0

    cidr_block = var.private_subnet_cidr_block
    vpc_ipv6_cidr_block = aws_vpc.main[0].ipv6_cidr_block
    ipv6_prefix = var.private_subnet_ipv6_prefix

    tags = merge(var.tags, var.private_subnet_tags)
}

module "database_subnet" {
  source = "./subnet"

  create = var.create_vpc && length(var.database_subnet_cidr_block)>0
  name   = var.name
  vpc_id = local.vpc_id
  azs    = var.azs

  subnet_type = "database"
  subgroup = var.create_database_subgroup

  map_public_ip_on_launch = false
  enable_ipv6 = var.enable_ipv6 && length(var.database_subnet_ipv6_prefix)>0

  cidr_block = var.database_subnet_cidr_block
  vpc_ipv6_cidr_block = aws_vpc.main[0].ipv6_cidr_block
  ipv6_prefix = var.database_subnet_ipv6_prefix

  tags = merge(var.tags, var.database_subnet_tags)
}

module "nat" {
    source = "./nat"
  
    name = var.name
    create = var.enable_nat
    nat_type = var.nat_type
    nat_count = local.nat_count

    vpc_id = local.vpc_id
    subnet_id = module.public_subnet.id
    azs = var.azs
    create_sg = true

    ingress_cidr_blocks = var.ingress_cidr_blocks
    cidr_blocks = [var.cidr_block]

    create_instance_profile = true
    key_name = var.nat_key_name
    instance_type = var.nat_instance_type

    reuse_nat_ips = var.reuse_nat_ips
    external_nat_ip_ids = var.external_nat_ip_ids

    tags = merge(var.tags, var.nat_tags)
}

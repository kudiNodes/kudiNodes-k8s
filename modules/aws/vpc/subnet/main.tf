resource "aws_subnet" "main" {
    count = var.create && length(var.cidr_block)>0 ? length(var.cidr_block) : 0

    vpc_id = var.vpc_id
    cidr_block = element(var.cidr_block, count.index)

    availability_zone    = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
    availability_zone_id = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) == 0 ? element(var.azs, count.index) : null

    map_public_ip_on_launch = var.map_public_ip_on_launch

    assign_ipv6_address_on_creation = var.enable_ipv6
    ipv6_cidr_block = var.enable_ipv6 && length(var.ipv6_prefix)>0 ? cidrsubnet(var.vpc_ipv6_cidr_block, 8, var.ipv6_prefix[count.index]) : null
    
    tags = merge(
        {
            "Name" = format("%s-%s-%s", var.name, var.subnet_type, element(var.azs, count.index)),
            "az" = element(var.azs, count.index)
            "type" = var.subnet_type
        },
        var.tags
    )
}

resource "aws_db_subnet_group" "database" {
    count = var.create && var.subgroup && var.subnet_type == "database" && length(var.cidr_block) > 0 ? 1 : 0

    name        = lower(var.name)
    description = "Database subnet group for ${var.name}"
    subnet_ids  = aws_subnet.main.*.id

    tags = merge(
      {"Name" = format("%s-database-sg", var.name)},
      var.tags,
    )
}
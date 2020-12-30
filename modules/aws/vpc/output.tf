output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.main[0].id
}

output "public_subnet_id" {
    description = "List of IDs for the public subnets"
    value = module.public_subnet.id
}

output "private_subnet_id" {
    description = "List of IDs for the private subnets"
    value = module.private_subnet.id
}

output "public_route_table_id" {
    description = "The public route table(s)"
    value = aws_route_table.public.*.id
}

output "private_route_table_id" {
    description = "The private route table(s)"
    value = aws_route_table.private.*.id
}

output "nat_eip" {
    description = "The eip assigned"
    value = module.nat.eip
}

output "nat_dns" {
    description = "The DNS for the eips"
    value = module.nat.public_dns
}

output "nat_gateway_id" {
    description = "The ID(s) for the NAT gateway"
#    value = var.enable_nat && var.nat_type == "gateway"
    value = module.nat.gateway_id
}

output "nat_instance_id" {
    description = "The ID(s) for the NAT instance"
    value = module.nat.instance_id
}

output "nat_security_group_id" {
    description = "The ID of the NAT security group"
    value = module.nat.security_group_id
}
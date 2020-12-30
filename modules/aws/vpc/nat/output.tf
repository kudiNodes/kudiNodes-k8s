output "gateway_id" {
    description = "The ID of the NAT gateway"
    value = aws_nat_gateway.nat.*.id
}

output "instance_id" {
    description = "The ID of the NAT instance"
    value = aws_instance.nat.*.id
}

output "security_group_id" {
    description = "The security group ids for the NAT instance"
    value = aws_security_group.nat_sg.*.id
}

output "eip" {
    description = "The IP addresses for the eip"
    #value = local.nat_ips
    value = aws_eip.nat.*.id
}

output "public_dns" {
    description = "The public DNS for the eip"
    value = aws_eip.nat.*.public_dns
}
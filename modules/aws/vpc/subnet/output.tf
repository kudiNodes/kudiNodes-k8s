output "id" {
    description = "The ID of the subnet"
    value = aws_subnet.main.*.id
}

# output "subnet_group_id" {
#     description = "The subnet group"
# }
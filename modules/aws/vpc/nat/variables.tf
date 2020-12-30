variable "create" {
  description = "Flag to create a NAT instance or gateway"
  type = bool
  default = false
}

variable "nat_type" {
  description = "The type of NAT to create (instance OR gateway)"
  type = string
  default = "instance"
}

variable "name" {
  description = "The name of NAT"
  type = string
  default = ""
}

variable "nat_count" {
  description = "The number of NAT instances to create"
  type = number
  default = 0
}

variable "reuse_nat_ips" {
  description = "Flag to re-use existing NAT ip addresses"
  type = bool
  default = false
}

variable "external_nat_ip_ids" {
  description = "List of external NAt"
  type = list(string)
  default = []
}

variable "vpc_id" {
  description = "The ID for the VPC"
  type = string
  default = ""
}

variable "cidr_blocks" {
  description = "List of CIDR blocks"
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "ingress_cidr_blocks" {
  description = "List of ingress CIDR blocks"
  type = list(string)
  default = ["0.0.0.0/0"]  
}

variable "subnet_id" {
  description = "List of subnet IDs"
  type = list(string)
  default = []
}

variable "azs" {
  description = "List of availability zones"
  type = list(string)
  default = []
}

variable "create_sg" {
  description = "Flag to create new security group"
  type = bool
  default = false
}

variable "security_groups" {
  description = "List of security groups to attach"
  type = list(string)
  default = []
}

variable "instance_profile" {
  description = "Instance profile to attach to the NAt instance"
  type = string
  default = ""
}

variable "create_instance_profile" {
  description = "Flag to create new role and instance profile"
  type = bool
  default = true
}

variable "key_name" {
  description = "Name of the key pair to use"
  type = string
  default = ""
}

variable "instance_type" {
  description = "The type of ec2 instance for the NAT"
  type = string
  default = "t2.nano"
}

variable "tags" {
  description = "set of tags for the NAT instance or gateway"
  type = map(string)
  default = {}
}

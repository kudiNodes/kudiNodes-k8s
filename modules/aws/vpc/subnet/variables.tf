variable "create" {
  description = "Flag to create a subnet"
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the VPC"
  type        = string
  default     = ""
}

variable "subgroup" {
  description = "Type of subgroup to create"
  type        = bool
  default     = false
}

variable "subnet_type" {
  description = "Type of subnet to create"
  type        = string
  default     = ""
}


variable "cidr_block" {
  description = "List of cidr blocks for the type of subnet"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "List of availability zones to create the subnet"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
  default     = ""
}

variable "map_public_ip_on_launch" {
  description = "Flag to enable mapping of public ip on launch"
  type        = bool
  default     = false
}

variable "enable_ipv6" {
  description = "Flag to enable ipv6"
  type        = bool
  default     = false  
}

variable "vpc_ipv6_cidr_block" {
  description = "The ipv6 CIDR block for the vpc"  
  type        = string
  default     = ""
}

variable "ipv6_prefix" {
  description = "List of ipv6 prefixes for the subnet"  
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags for the subnet"
  type        = map(string)
  default     = {}
}
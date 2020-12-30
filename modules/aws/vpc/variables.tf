variable "create_vpc" {
    description = "Flag to create VPC"
    type = bool
    default = true
}

variable "name" {
    description = "Name to be used for the VPC resource"
    type = string
    default = ""
}

variable "domain_name" {
    description = "Domain name"
    type = string
    default = ""
}

variable "tags" {
    description = "map of tags to add to all resources"
    type = map(string)
    default = {}
}

variable "cidr_block" {
    description = "The CIDR block for the VPC"
    type = string
    default = "0.0.0.0/0"
}

variable "secondary_cidr_blocks" {
    description = "List of secondary CIDR blocks to associate with the VPC"
    type = list(string)
    default = []    
}

variable "enable_dns_hostnames" {
    description = "Flag to enable DNS hostnames"
    type = bool
    default = true
}

variable "enable_dns_support" {
    description = "Flag to enable DNS hostnames"
    type = bool
    default = true
}

variable "enable_dhcp_options" {
    description = "Flag to enable dhcp options"
    type = bool
    default = false
}

variable "enable_ipv6" {
    description = "Flag to enable ipv6"
    type = bool
    default = false
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = []
}

variable "map_public_ip_on_launch" {
    description = "map public ip on launch"
    type = bool
    default = true
}

variable "public_subnet_cidr_block" {
  description = "List of public subnet cidr block"
  type        = list(string)
  default     = []
}

variable "public_subnet_ipv6_prefix" {
  description = "List of public subnet ipv6 prefix"
  type        = list(string)
  default     = []
}

variable "public_subnet_tags" {
    description = "set of tags for the public subnet"
    type = map(string)
    default = {}
}

# Private subnet
variable "private_subnet_cidr_block" {
  description = "List of private subnet cidr block"
  type        = list(string)
  default     = []
}

variable "private_subnet_ipv6_prefix" {
  description = "List of private subnet ipv6 prefix"
  type        = list(string)
  default     = []
}

variable "private_subnet_tags" {
    description = "set of tags for the private subnet"
    type = map(string)
    default = {}
}

# Database subnet
variable "database_subnet_cidr_block" {
  description = "List of database subnet cidr block"
  type        = list(string)
  default     = []
}

variable "database_subnet_ipv6_prefix" {
  description = "List of database subnet ipv6 prefix"
  type        = list(string)
  default     = []
}

variable "database_subnet_tags" {
  description = "set of tags for the  subnet"
  type = map(string)
  default = {}
}

variable "create_database_subgroup" {
  description = "Flag to create subgroup for database subnet"
  type        = bool
  default     = false
}

variable "enable_nat" {
  description = "Flag to enable NAT gateway/instance"
  type        = bool
  default     = false
}

variable "nat_type" {
  description = "Type of NAT"
  type        = string
  default     = "instance"
}

variable "single_nat" {
  description = "Flag to specify single NAT for environment"
  type        = bool
  default     = false
}

variable "reuse_nat_ips" {
  description = "Flag to disable creation of EIPs for NAT. IPs will be managed through 'external_nat_ip_ids' variable"
  type        = bool
  default     = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT instead of creating EIPs"
  type        = list(string)
  default     = []
}

variable "nat_instance_type" {
  description = "The instance type for the NAT"
  type        = string
  default     = "t2.nano"
}

variable "nat_key_name" {
  description = "The key name for the NAT instance"
  type        = string
  default     = ""
}

variable "nat_key_location" {
  description = "The key location for the NAT instance"
  type        = string
  default     = ""
}

variable "ingress_cidr_blocks" {
  description = "The allowed cidr blocks for ingress access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nat_tags" {
  description = "Additional tags for the NAT instances/gateways"
  type        = map(string)
  default     = {}
}
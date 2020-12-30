provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "../"

    create_vpc = true
    name = "test"
    domain_name = "alphega.io"
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    enable_dhcp_options = false

    enable_ipv6 = true
    enable_nat = true

    azs = ["us-east-1a", "us-east-1b"]

    public_subnet_cidr_block = ["10.0.1.0/24", "10.0.2.0/24"]
    private_subnet_cidr_block = ["10.0.3.0/24", "10.0.4.0/24"]
    database_subnet_cidr_block = ["10.0.5.0/24", "10.0.6.0/24"]

    create_database_subgroup = true

    tags = {
        "Environment" = "example"
    }
}


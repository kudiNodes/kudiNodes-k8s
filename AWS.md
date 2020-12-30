# KudiNodes Kubernetes Infrastructure

## VPC Network
| Name                      | Description                                                                                                                                                                    | Type         | Default       |
|---------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|---------------|
| create_vpc                | Flag to create VPC                                                                                                                                                             | bool         | false         |
| vpc_id                    | Identifier for an existing VPC to use                                                                                                                                          | string       |               |
| cidr_block                | CIDR block for the vpc network to be created                                                                                                                                   | string       | 172.16.0.0/24 |
| public_subnet_cidr_block  | List of CIDR blocks for the public subnet in the VPC                                                                                                                           | list(string) |               |
| private_subnet_cidr_block | List of CIDR blocks for the private subnet in the VPC                                                                                                                          | list(string) |               |
| enable_dns_hostnames      | Flag to enable DNS hostnames                                                                                                                                                   | bool         |               |
| enable_dns_support        | Flag to enable DNS support                                                                                                                                                     | bool         |               |
| enable_ipv6               | Flag to enable IPV6                                                                                                                                                            | bool         |               |
| nat_type                  | Type of NAT device to be created<br>instance - create an ec2 instance<br>gateway - create a NAT Gateway                                                                        | string       | instance      |
| nat_key_name              | The ec2 key pair name to be used for accessing the NAT instance.<br>The instance will not be accessible if a value is not provided.                                            | string       |               |
| nat_instance_type         | The type of ec2 instance for the NAT device when an instance type is selected.<br>Reference ec2 documentation for available options https://aws.amazon.com/ec2/instance-types/ | string       | t2.nano       |
## EKS Cluster

## ECR

## S3

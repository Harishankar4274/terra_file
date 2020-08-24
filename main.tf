provider "aws" {
    region = "ap-south-1"
    profile = "default"
}

// creating vpc start
module "aws_vpc" {
    source = "./aws_vpc/"
}
// creating vpc end

// output data: vpc+sg
output "private_sg_id" {
    value = module.aws_vpc.private_sg_id
}

output "public_sg_id" {
    value = module.aws_vpc.public_sg_id
}

output "private_subnet_id" {
    value = module.aws_vpc.private_subnet_id
}

output "public_subnet_id" {
    value = module.aws_vpc.public_subnet_id
}

output "vpc_id" {
    value = module.aws_vpc.vpc_id
}

locals {
    vpc_id = module.aws_vpc.vpc_id
    public_subnet_id = module.aws_vpc.public_subnet_id
    private_subnet_id = module.aws_vpc.private_subnet_id
    private_sg_id = module.aws_vpc.private_sg_id
    public_sg_id = module.aws_vpc.public_sg_id
}

/*
// creating efs_file_system start
module "efs" {
    source = "./efs/"
}
// creating efs_file_system start

// output data: efs
output "efs_file_system_id" {
  value = module.efs.efs_file_system_id
}

output "efs_access_point_id" {
	value = module.efs.efs_access_point_id
}

output "efs_mount_target_id" {
	value = module.efs.efs_mount_target_id
}

// creating ec2 instance start
module "aws_ec2" {
    source = "./aws_ec2/"    
}
// creating ec2 instance end
*/
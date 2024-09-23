module "bitcube_ec2_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bitcube_sg"
  description = "Security group for my EC2 with HTTP and SSH ports open within VPC"
  vpc_id      = module.vpc.vpc_id

    /*===Inbound Rules===*/
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"  
      description = "Allow SSH from your IP address"
    },
     {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTP outbound traffic"
    },
     {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow ICMP inbound traffic to ping instances"
    }
  ]

    /*===Outbound Rules===*/
   egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  ]

}

output "security_group_id" {
  value = module.bitcube_ec2_sg.security_group_id
}

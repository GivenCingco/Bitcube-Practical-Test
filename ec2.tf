module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Bitcube-ec2"

  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_pair_name
  monitoring                  = false
  vpc_security_group_ids      = [module.bitcube_ec2_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  ami                         = "ami-0ebfd941bbafe70c6"
  iam_instance_profile        = aws_iam_instance_profile.bitcube_ec2_instance_profile.name

  user_data = <<-EOF
                    #!/bin/bash
                    set -e  # Exit immediately if a command exits with a non-zero status

                    # Update the instance
                    sudo yum update -y

                    # Install necessary packages
                    sudo yum install -y ruby wget

                    # Install Docker
                    sudo yum -y install docker
                    sudo service docker start
                    sudo systemctl enable docker
                    sudo usermod -a -G docker ec2-user
                    sudo chmod 666 /var/run/docker.sock

                    # Install CodeDeploy agent
                    cd /home/ec2-user
                    wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
                    chmod +x ./install
                    sudo ./install auto

                    # Start the CodeDeploy agent service
                    sudo service codedeploy-agent start
EOF

  tags = {
    Name        = "Bitcube-ec2"
    Environment = "BitcubeCodeDeploy"
  }
}

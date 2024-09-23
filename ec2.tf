module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "Bitcube-ec2"

  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  monitoring             = false
  vpc_security_group_ids = [module.bitcube_ec2_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  associate_public_ip_address = true 
  ami                    = "ami-0ebfd941bbafe70c6"
  iam_instance_profile = aws_iam_instance_profile.bitcube_ec2_instance_profile.name
  
  user_data = <<-EOF

              #!/bin/bash
              # Update the instance
              yum update -y

              # Install necessary packages
              yum install -y ruby wget nginx

              # Start and enable Nginx
              systemctl start nginx
              systemctl enable nginx

              # Install CodeDeploy agent
              cd /home/ec2-user
              wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto

              # Start the CodeDeploy agent service
              service codedeploy-agent start

              # Remove the default server block
              rm -f /etc/nginx/conf.d/default.conf

              yum remove -y nodejs

              # Install Node.js and npm (change to Node.js 18)
              curl -sL https://rpm.nodesource.com/setup_18.x | bash -
              yum install -y nodejs

              # Create a symbolic link for node
              ln -s /usr/bin/nodejs /usr/bin/node

              # Update PATH
              echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile

              # Verify installations and log the output
              {
                  echo "Node.js path: $(which node)"
                  echo "NPM path: $(which npm)"
                  echo "Node version: $(node -v)"
                  echo "NPM version: $(npm -v)"
              } >> /var/log/user-data.log 2>&1

              # Verify installations
              node -v
              npm -v

              # Optional: restart Nginx to apply configurations
              systemctl restart nginx

              EOF

  tags = {
    Name = "Bitcube-ec2"
    Environment = "BitcubeCodeDeploy"
  }
}
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y python3
                pip3 install Flask boto3
                cd /home/ec2-user
                echo 'BUCKET_NAME=your-bucket-name' >> /etc/environment
                source /etc/environment
                wget https://path-to-your-app/app.py
                python3 /home/ec2-user/app.py
                EOF

  tags = {
    Name = "Flask-S3-Service"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow web traffic"
   ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web_url" {
  value = aws_instance.web.public_ip
}

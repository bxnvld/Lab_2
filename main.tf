provider "aws" {
  region = "us-east-1" 
}

resource "aws_security_group" "my_security_group" {
  name        = "prometheus_sg"
  description = "Security Group for Prometheus server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "first_ec2_instance" {
  ami           = "ami-0c94855ba95c71c99" 
  instance_type = "t2.micro" 

  subnet_id        = aws_subnet.my_subnet.id
  security_group   = aws_security_group.my_security_group.id
  associate_public_ip_address = true

  tags = {
    Name = "First EC2 Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io

              # Запуск Prometheus
              docker run -d -p 9090:9090 --name prometheus prom/prometheus

              # Запуск Node-exporter
              docker run -d -p 9100:9100 --name node-exporter prom/node-exporter

              # Запуск Cadvizor-exporter
              docker run -d -p 8080:8080 --name cadvizor-exporter google/cadvisor:latest
              EOF

  provisioner "remote-exec" {
    inline = [
      "echo 'Additional remote-exec command for first EC2'",
      "echo 'Example command for first EC2'"
    ]
  }
}

resource "aws_instance" "second_ec2_instance" {
  ami           = "ami-0c94855ba95c71c99" 
  instance_type = "t2.small" 

  subnet_id        = aws_subnet.my_subnet.id
  security_group   = aws_security_group.my_security_group.id
  associate_public_ip_address = true

  tags = {
    Name = "Second EC2 Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y docker.io

              # Запуск Node-exporter
              docker run -d -p 9100:9100 --name node-exporter prom/node-exporter

              # Запуск Cadvizor-exporter
              docker run -d -p 8080:8080 --name cadvizor-exporter google/cadvisor:latest
              EOF


  provisioner "remote-exec" {
    inline = [
      "echo 'Additional remote-exec command for second EC2'",
      "echo 'Example command for second EC2'"
    ]
  }
}
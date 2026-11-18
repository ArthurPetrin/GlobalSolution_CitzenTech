resource "aws_security_group" "web_sg" {
  name        = "citizentech-sg"
  description = "Acesso HTTP publico e saida liberada"

  ingress {
    description = "HTTP Publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Porta alternativa da aplicacao"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus Node Exporter"
    from_port   = 9100
    to_port     = 9100
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

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data_replace_on_change = true

  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable --now docker
    docker run -d --name web --restart always -p 80:8080 arthurwp/citizentech:latest
    docker run -d --name node-exporter --restart always --net host --pid host -v /:/host:ro,rslave prom/node-exporter:v1.8.1 --path.rootfs=/host
    printf '*/2 * * * * root docker pull arthurwp/citizentech:latest | grep -q "Downloaded newer" && docker rm -f web && docker run -d --name web --restart always -p 80:8080 arthurwp/citizentech:latest\n' > /etc/cron.d/redeploy
    chmod 0644 /etc/cron.d/redeploy
  EOF

  tags = {
    Name    = "CitizenTech-MVP"
    Project = "CitizenTech"
  }
}
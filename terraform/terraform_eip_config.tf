# ======= Elastic IP and Association for Blue-Green =======
resource "aws_eip" "app_ip" {
  tags = {
    Name = "InventoWareAppElasticIP"
  }
}
# Attach to a single EC2 instance launched via a launch template (static instance for EIP)
resource "aws_instance" "blue_green_static" {
  ami                         = "ami-0becc523130ac9d5d"
  instance_type               = "t3.medium"
  subnet_id                   = data.aws_subnets.public.ids[0]
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "InventoWare-EIP-Instance"
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
EOF
  )
}

resource "aws_eip_association" "app_assoc" {
  instance_id   = aws_instance.blue_green_static.id
  allocation_id = aws_eip.app_ip.id
}

output "app_eip" {
  description = "Elastic IP for universal access to the deployment server"
  value       = aws_eip.app_ip.public_ip
}

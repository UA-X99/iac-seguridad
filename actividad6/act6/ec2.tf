locals {
  instance_count = 2
  instance_name  = "act6-alejandro1-diego2"
}


resource "aws_instance" "alejandro_server_terr" {
  count = local.instance_count
  ami   = "ami-06a974f9b8a97ecf2"

  instance_type = var.instance_type

  tags = {
    Name = local.instance_name
  }
}


output "alejandro_server_terr" {
  value = aws_instance.alejandro_server_terr
}
# vm.tf
resource "aws_instance" "alejandro_server_terr_extra" {
  ami = "ami-06a974f9b8a97ecf2"

  instance_type = "t3.micro"

  tags = {
    Name = "alejandro_server_terr_extra"
  }
}

output "alejandro_server_terr_extra" {
  value = aws_instance.alejandro_server_terr_extra.public_ip
}
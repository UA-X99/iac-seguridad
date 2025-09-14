resource "aws_instance" "alejandro_server_terr" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 en us-west-2
  instance_type = "t2.micro"

  tags = {
    Name = "alejandro_server_terr"
  }
}

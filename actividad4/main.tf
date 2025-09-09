terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider 
provider "aws" {
  region = "us-west-2"
}

# Primera instancia EC2
resource "aws_instance" "alejandro_server_terr_1" {
  ami           = "ami-03aa99ddf5498ceb9"
  instance_type = "t3.micro"
  key_name      = "alejandro-key"

  tags = {
    Name = "alejandroServerTerraform1"
  }
}

# Segunda instancia EC2
resource "aws_instance" "alejandro_server_terr_2" {
  ami           = "ami-075401717f89f691f"
  instance_type = "t4g.small"

  tags = {
    Name = "alejandroServerTerraform2"
  }
}

# Bucket S3
resource "aws_s3_bucket" "mi_bucket" {
  bucket = "bucket-alejandrohernandez-terraform"
  acl    = "private"

  tags = {
    Name        = "BucketAlejandroTerraform"
    Environment = "Dev"
  }
}

# Outputs
output "server_alejandro_1" {
  value = aws_instance.alejandro_server_terr_1.tags.Name
}

output "server_alejandro_2" {
  value = aws_instance.alejandro_server_terr_2.tags.Name
}

output "bucket_name" {
  value = aws_s3_bucket.mi_bucket.id
}

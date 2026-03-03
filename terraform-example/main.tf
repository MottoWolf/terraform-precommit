resource "aws_instance" "example" {
  ami           = "ami-0288fe907d08237c80"
  instance_type = "t3.micro"
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_tokens = "required"
  }
  tags = {
    Name = "example"
  }
}


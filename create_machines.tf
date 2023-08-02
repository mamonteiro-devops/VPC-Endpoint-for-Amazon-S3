# Generating a private_key
resource "tls_private_key" "endptkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private-key" {
  content  = tls_private_key.endptkey.private_key_pem
  filename = "endptkey.pem" #naming our key pair so that we can connect via ssh into our instances
}

resource "aws_key_pair" "deployer" {
  key_name   = "endptkey"
  public_key = tls_private_key.endptkey.public_key_openssh
}

resource "aws_instance" "public_instance" {
  ami                    = var.public_instance
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.My_VPC_Subnet_Public.id
  iam_instance_profile = aws_iam_instance_profile.ec2profile.name
  key_name               = var.key_name # insert your key file name here
  vpc_security_group_ids = [aws_security_group.My_VPC_Security_Group_Public.id]
  tags = {
    Name = "public_instance"
  }
}

resource "aws_instance" "private_instance" {
  ami                    = var.private_instance
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.My_VPC_Subnet_Private.id
  key_name               = var.key_name # insert your key file name here
  vpc_security_group_ids = [aws_security_group.My_VPC_Security_Group_Private.id]
  iam_instance_profile = aws_iam_instance_profile.ec2profile.name
  tags = {
    Name = "private_instance"
  }
}
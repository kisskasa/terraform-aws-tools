module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-tf"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-07a9ee59fdaf1fb47"] #replace your SG
  subnet_id = "subnet-0440d6210cca062b1" #replace your Subnet
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins.sh")
  tags = {
    Name = "jenkins-tf"
  }
}

module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-agent"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-07a9ee59fdaf1fb47"]
  # convert StringList to list and get first element
  subnet_id = "subnet-0440d6210cca062b1"
  ami = data.aws_ami.ami_info.id
  user_data = file("jenkins-agent.sh")
  tags = {
    Name = "jenkins-agent"
  }
}

resource "aws_key_pair" "tools" {
  key_name   = "tools"
  # you can paste the public key directly like this
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCyEbSG+6z8tQovLOdwNOdSlBRi9cObtulDyxC/TiYTXXIo5lW7sqeVOLpKtVj6Uv6L4mPLU8u1Nl9TcgkXyxzRjBRxQcbnhRso60dtrwTJI6n8fAYn0GEjlaI8h757+1nTgc8Noj7iVhUUsKsNsZ7PS674kLp/YmmD5Cw7gB0bN6Bzl21WtVklLCld4RNj58ZI74xXP0or7nZW32uvNXH2V3Qj5KILEqRdD0VS3RIvbpj+Vl9w5RDcQ0wRd3/OMS1a/FL7n+rRzG02SydKSSal3XHLd3az0NLurx7A6qiqII0H23SuwYzQcVXNhECQpJg+VBNIAfgmBIjau4L+MjHvH13gMe+gX114tvwQ4X/yq5xg03SrU8/NNr2mmppuAK6wfCJV6zsghMy51Ino5pB7wU5OypLhofviQTrajQwu669wJsHERwEiyhVpEef1MkJFTlMPxO6ye0AA9/36XiZEjlH76Wj/sZcF2foS42fYz5kyHfCh3+o+X6hPJLBR8G6yPkbeS5xHvDJPutYacXkEJj7egA8ZKvFfkiSLPOe88pr5lzovdd0NOry9h3YEX7aSK7MuAg1pkPYuJZv2+qy8kpEw1CZeUXlm9QuD3yurd4KnIop1P/DBdEbRranFaZf2tlhNYFD7ATEL8SG7AbPXfhbXSdCvhKzMEnIyoNXLsw== Chandrakasa@DESKTOP-FSJLPI9"
  #public_key = file("~/.ssh/tools.pub")
  # ~ means windows home directory
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins_agent.private_ip
      ]
    }    
  ]

}
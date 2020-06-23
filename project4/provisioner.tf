resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}
resource "aws_instance" "centos" {
  ami               = "${data.aws_ami.centos.id}"
  key_name          = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.allow_tls.id}"]
  subnet_id         = "${aws_subnet.public1.id}"
  associate_public_ip_address = true
  source_dest_check = false
#   security_groups = ["${aws_security_group.allow_tls.name}"]
  user_data = "${file("nagios.sh")}"
  instance_type = "t3.medium"
#   provisioner   "remote-exec" {
#     connection {
#         host        = "${self.public_ip}"
#         type        = "ssh"
#         user        = "centos"
#         private_key = "${file("~/.ssh/id_rsa")}"
#     }
#     inline = [
#         "sudo setenforce 0",
#         "sudo yum install epel-release -y",
# 	    "sudo yum install curl -y",
#         "sudo curl  https://assets.nagios.com/downloads/nagiosxi/install.sh | sh",
#     ]
#   }
tags = {
    Name = "NagiosProject"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 5693
    to_port     = 5693
    protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "tf-vpc"
  }
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "tf-subnet"
  }
}



resource "aws_instance" "ec2_example" {

    ami = "ami-0ed9277fb7eb570c9"  
    instance_type = "t2.micro" 
    key_name= "aws_key"
    vpc_security_group_ids = [aws_security_group.main.id]
    tags = {
        Name= "tf-jenkins"
    }


  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
      "mkdir Project",
      "cd Project",
      "sudo yum install epel-release",
      "sudo amazon-linux-extras install epel -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
      "sudo yum upgrade -y",
      "sudo yum install java -y",
      "sudo yum install java* -y --skip-broken",
      "sudo yum install jenkins -y",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
      "sudo yum install python3 -y",
      "sudo yum install firewall* -y",
      "sudo systemctl start firewalld",
      "sudo systemctl enable firewalld",
      "sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent",
      "sudo firewall-cmd --zone=public --add-service=http --permanent",
      "sudo firewall-cmd --reload",
      "sudo firewall-cmd --list-all",
      
      

    ]
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("/home/ec2-user/Project/tf-instance/aws/aws_key")
      timeout     = "4m"
   }
}

resource "aws_security_group" "main" {
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = ""

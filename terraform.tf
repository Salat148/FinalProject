provider "aws" {
  shared_credentials_file = "/.aws/credentials"
  region     = "us-east-1"
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-08bc77a2c7eb2b1da"
  instance_type          = "t2.micro"
  key_name               = "apache_server"
  vpc_security_group_ids = ["sg-0bf4d379cd8bae076"]

 provisioner "remote-exec" {
    inline = [
	"sudo apt update && apt -y upgrade",
	"sudo apt -y install git",
        "sudo apt -y install openjdk-8-jdk",
        "sudo wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -",
        "sudo echo deb http://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list",
        "sudo apt update",
        "sudo apt -y install jenkins",
        "sudo systemctl start jenkins",
       ]
  }

 connection {
	host = self.public_ip
	user = "ubuntu"
	type = "ssh"
	private_key = "${file("/home/ubuntu/.ssh/apache_server.pem")}"
	}
}


resource "aws_instance" "docker" {
  ami                    = "ami-08bc77a2c7eb2b1da"
  instance_type          = "t2.micro"
  key_name               = "apache_server"
  vpc_security_group_ids = ["sg-0bf4d379cd8bae076"]

 provisioner "remote-exec" {
    inline = [

        "sudo apt update && -y upgrade",
        "sudo apt -y install openjdk-8-jdk",
        "sudo sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D",
        "sudo sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'",
        "sudo apt update",
        "sudo apt install -y docker-engine",
        "sudo usermod -aG docker $(whoami)",
	"sudo usermod -aG docker ubuntu",
	"sudo curl -o /usr/local/bin/docker-compose -L 'https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)'",
	"sudo chmod +x /usr/local/bin/docker-compose",
	"sudo mkdir project/src",
	]
  }

 provisioner "file" {
    source      = "./project/src/Dockerfile"
    destination = "./project/src"
  }

 connection {
        host = self.public_ip
        user = "ubuntu"
        type = "ssh"
        private_key = "${file("/home/ubuntu/.ssh/apache_server.pem")}"
        }
}


data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210430"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }
}

data "aws_vpc" "my-vpc" {
  filter {
    name = "tag:Name"
    values = ["my-vpc"]
  }
}



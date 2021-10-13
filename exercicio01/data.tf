data "aws_ami" "slacko-app" {
    most_recent = true
    owners = ["amazon"]

    filter {
        name = "name"
        values = ["Amazon*"]
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



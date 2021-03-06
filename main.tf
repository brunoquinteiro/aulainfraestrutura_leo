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

data "aws_subnet" "subnet_public"{
    cidr_block = "10.0.102.0/24"
} 

resource "aws_key_pair" "slacko-sshkey" {
    key_name = "slacko-app-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/qyBn75oHPZlG7GXpHd/rUAsDXuEl6svMirXh7kFSjfNYJ4H8gX37pMvsyAy2GkKFtcJ5Ljo98IQAxVCy8sk+HJTATOm6UB9xyKkmCuiartfOHPWwKHguCkmyPqdG5hDzJlEYs9uL6XCRvTa9nI0dykCheVw9+wdfsFIvfwsQVxdtH+hqmixAFxSAT2epNHf5v3mWO/9DnNAwpDr5HaFGTWumse9+ejXhJro0L2c6p/bZZSQvUPYUeD5qeFWs+YZ+J4fn/kwg6H92q/F+y0LDpsD1NmulgEE9New9StNjXVIh787Jd8H7KL0lb/TfZPuFNDf71dhBxTQC1rYBPGMFfP249nM8di2rADVmd8FjrCc6ShLaSy43z2mClG3n5j8n7sGcpjVsGBMCidVCW5HrXB1gRr3giVTeoVLnffsUM9oo59LAxgbhHqpseaCAZqUVexRO4lq/m6Ms6X8Ex9hTIOWjNx/DHz15DC/O4NaELDl1W6hEYkSkZSBIBUWPdQs= vagrant@iaac-station"
}

resource "aws_instance" "slacko-app" {
    ami = data.aws_ami.slacko-app.id
    instance_type = "t2.micro"
    subnet_id = data.aws_subnet.subnet_public.id
    associate_public_ip_address = true

    tags = {
        Name = "Slacko-app"
    }
    key_name = aws_key_pair.slacko-sshkey.id
    user_data = file("ec2.sh") 
}

resource "aws_instance" "mongodb" {
    ami = data.aws_ami.slacko-app.id
    instance_type = "t2.small"
    subnet_id = data.aws_subnet.subnet_public.id
 
    tags = {
        Name = "MongoDb"
    }

    key_name = aws_key_pair.slacko-sshkey.id
    user_data = file("mongodb.sh") 
}

resource  "aws_security_group" "allow_slacko"{
    name = "allow_ssh_http"
    description = "Allow ssh and https port"
    ## coloque o seu vpcid aqui... 
    #vpc_id = "vpc-04abb2842c988bfa5"
    vpc_id = data.aws_vpc.my-vpc.id
    
    ingress = [
        {
            description = "Allow SSH"
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null
        },
        {
            description = "Allow http"
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null
        }
    ]
    egress = [
        {
            description = "Allow all"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null
        }      
    ]
    tags = {
        Name = "Allow_ssh_http"
    }

}

resource "aws_security_group" "allow-mongodb"{
    name = "allow_mongodb"
    description = "Allow MongoDb"
    #vpc_id = "vpc-04abb2842c988bfa5"
    vpc_id = data.aws_vpc.my-vpc.id

    ingress = [
        {
            description = "Allow MOngoDB"
            from_port = 27017
            to_port = 27017
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null

        }
    ]
    egress = [
        {
            description = "Allow all"
            from_port = 0
            to_port = 0
            protocol = "all"
            cidr_blocks = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
            prefix_list_ids = null
            security_groups = null
            self = null

        }

    ]

    tags = {
        Name = "allow_mongodb"
    }


}
## associando o sg
resource "aws_network_interface_sg_attachment" "mongo-sg" {
    security_group_id = aws_security_group.allow-mongodb.id
    network_interface_id = aws_instance.mongodb.primary_network_interface_id
}

## associando o SG
resource "aws_network_interface_sg_attachment" "slacko-sg" {
    security_group_id = aws_security_group.allow_slacko.id
    network_interface_id = aws_instance.slacko-app.primary_network_interface_id
}

resource "aws_route53_zone" "slack_zone" {
    name = "iaac0506.com.br"
    vpc{
        #vpc_id = "vpc-04abb2842c988bfa5"
        vpc_id = data.aws_vpc.my-vpc.id
    }
    
}

resource "aws_route53_record" "mongodb" {
    zone_id = aws_route53_zone.slack_zone.id
    name = "mongodb.iaac0506.com.br"
    type = "A"
    ttl = "3600"
    records = [aws_instance.mongodb.private_ip]
}
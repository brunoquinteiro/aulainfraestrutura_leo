data "aws_subnet" "subnet_public"{
    cidr_block = var.subnet_cidr
} 

resource "aws_key_pair" "jenkins-sshkey" {
    key_name = "${var.prefix_name}-jenkins-app-key"
    public_key = var.your_ssh_key
}

resource "aws_instance" "jenkins-app" {
    ami = var.ami
    instance_type = var.shape_app 
    subnet_id = data.aws_subnet.subnet_public.id
    associate_public_ip_address = true
    tags = merge(var.tags,{Name = "${var.prefix_name}-jenkins-app"})
    key_name = aws_key_pair.jenkins-sshkey.id
    user_data = file ("${path.module}/files/ec2.sh") 
}

resource  "aws_security_group" "allow_jenkins"{
    name = "${var.prefix_name}-SG-allow_ssh_8080"
    description = "Allow protocol SSH and HTTP"
    vpc_id = var.vpc_id
    tags = merge(var.tags,{Name = "${var.prefix_name}-SG-allow_ssh_http"})
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
            description = "Allow HTTP 8080"
            from_port = 8080
            to_port = 8080
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
            description = "Allow ALL Trafic Out"
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
}

resource "aws_network_interface_sg_attachment" "jenkins-sg" {
    security_group_id = aws_security_group.allow_jenkins.id
    network_interface_id = aws_instance.jenkins-app.primary_network_interface_id
}
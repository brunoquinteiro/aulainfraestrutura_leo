module "mod_jenkins" {
    source = "./modules/mod_jenkins"
    vpc_id = data.aws_vpc.my-vpc.id
    ami = data.aws_ami.ubuntu.id
    
    subnet_cidr = "10.0.102.0/24"
    prefix_name = "Exercicio-02"
    your_ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnr9CGshYC3mOpt6p536u5MkG7BuPI7K/tewKhNt+D7M1PxNlZ3bmORvluHQqHdIA9HPTN3/IQ7Ggzzgk1CvfYG/lDIReaRsIv1IQBhhFSVJOFvkAfH/PS3s/fILeF0nZAVvZsfABkQnoIPhqPmTxNmxh0BPiNubntvgu7Z1oh7OaN0Zgc5H3xIHtpsLJbO5kqGxqw9iXUAMNw1JKDqn7ht+5SMzpSDjyJ5JTRKIM9oim5NIs/AVLHM0l8HewW0tV6UjWMB5ry+B1NM56OyOnyLBCUqqpZWqtyJXEtB9ZCAXEf1fTJbYK+rpJUyOZbKvOEFREZSiB47VHtvjVcr3E9YZ5BI7xNlrDVO0BFEiDQWPkjx3jpN7f5S087ZpSBqCvlk3h2frJcPzW2+PHOMrR4kB6ypPtz7i5IokArCDc7wirzG0qf4DDLOuOBMpn1jlzPwHLUta7WlOcv5/pPqGNt0z9l8nzMEgy50s+9WiDBITgOSnsUS7JbYD1X/VAcMpc= vagrant@iaac-station"
    shape_app = "t2.small"
    tags = {
        Materia = "CIA"
        Faculdade = "Impacta"
        Aluno = "Bruno Quinteiro"
        Turma = "CLC"
        Professor = "Leonardo"
    }
}

resource "null_resource" "PassJenkins" {
    triggers = {
        instance = module.mod_jenkins.jenkins-app
    }
    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = file("${path.module}/modules/mod_jenkins/files/id_rsa")
        host = module.mod_jenkins.jenkins-app
    }
    provisioner "remote-exec" {
    inline = [
        "sleep 300",
        "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
    ]
  }
}

output "jenkinsIP" {
    value = module.mod_jenkins.jenkins-app
}


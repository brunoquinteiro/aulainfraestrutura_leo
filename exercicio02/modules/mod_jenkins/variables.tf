variable "subnet_cidr" {
    description = "Informe o seguimento de rede da SubNet"
    type = string
    default = "10.0.102.0/24"
}

variable "your_ssh_key" {
    description = "Informe a conteúdo da sua chave ssh publica"
    type = string
}

variable "ami"{
    description = "Informe a ami a ser utilizada"
    type = string
}

variable "vpc_id" {
    description = "informe o nome da VPC utilizada"
    type = string
}

variable "prefix_name" {
    description = "Nome do Projeto a ser concatenado ao nome do recurso"
    type = string
}

variable "tags" {
    default = {
        Curso = "MBA"
        Faculdade = "Impacta"
        Aluno = "Mario"
        Turma = "CLC-06"
    }
}

variable "shape_app" {
    description = "Shape do servidor AWS EC2"
    type = string
    default = "t2.micro"
}
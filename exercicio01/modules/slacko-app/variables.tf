variable "subnet_cidr" {
    type = string
    default = "10.0.102.0/24"
}

variable "your_ssh_key" {
    type = string
}

variable "ami"{
    type = string
}

variable "vpc_id" {
    description = "informe aqui o nome da VPC utilizada"
    type = string
}

variable "prefix_name" {
    description = "nome a ser concatenado ao nome do recurso"
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
    description = "Shape da máquina de App"
    type = string
    default = "t2.micro"
}

variable "shape_mongo" {
    description = "Shape da máquina de Mongo"
    type = string
    default = "t2.micro"
}
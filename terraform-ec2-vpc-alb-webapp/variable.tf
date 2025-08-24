
variable "vpc-cidr" {
  default = "192.168.0.0/16"
}

variable "subnet-pu1" {
  default = "192.168.1.0/24"
}

variable "subnet-pu2" {
  default = "192.168.2.0/24"
}

variable "subnet-priv" {
  default = "192.168.11.0/24"
}

variable "ami" {
  default = "ami-0861f4e788f5069dd"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ingress_rule" {
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    description = string 
  }))
  default = [ 
    { from_port = 22, to_port = 22, protocol = "tcp", description = "allow ssh protocol"},
    { from_port = 80, to_port = 80, protocol = "tcp", description = "allow http protocol"},
    {from_port = 0, to_port = 0, protocol = "tcp", description = "allow ping "}
     ]
}

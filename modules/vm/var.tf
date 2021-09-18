variable "win_ami" {
}
variable "instance_type" {
}
variable "vpc_id" {
}
variable "key_name" {
}
variable "security_group_name" {
}
variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
}

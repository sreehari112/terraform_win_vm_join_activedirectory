variable "win_ami" {
default = "ami-06b638312ebaceb03"
}
variable "instance_type" {
type = string
default = "t2.medium"
}
variable "vpc_id" {
default = "vpc-5f326e27"
}
variable "key_name" {
type = string
default = "achutseptber"
}
variable "security_group_name" {
type = string
default = "ec2-sg"
}
variable "ingress_rules" {
    type = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_block  = string
      description = string
    }))
    default     = [
        {
          from_port   = 3389
          to_port     = 3389
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "RDP"
        },
        {
          from_port   = 5985
          to_port     = 5986
          protocol    = "tcp"
          cidr_block  = "0.0.0.0/0"
          description = "winrm"
        },
    ]
}

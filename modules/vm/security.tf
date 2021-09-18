resource "aws_security_group" "this" {
  name        = var.security_group_name
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id
}
resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.ingress_rules)

  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = [var.ingress_rules[count.index].cidr_block]
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.this.id
}
resource "aws_security_group_rule" "allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 # prefix_list_ids   = [aws_vpc_endpoint.my_endpoint.prefix_list_id]
  from_port         = 0
  security_group_id = aws_security_group.this.id
}

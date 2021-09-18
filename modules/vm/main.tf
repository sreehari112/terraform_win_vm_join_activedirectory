
resource "aws_instance" "win-example" {
ami = var.win_ami
instance_type = var.instance_type
key_name = var.key_name
#user_data     = "${local_file.user_data.content}"
vpc_security_group_ids=["${aws_security_group.this.id}"]
iam_instance_profile        = aws_iam_instance_profile.ec2-ssm-role-profile.name
}

#data "template_file" "user_data" {
#  template = "${file("iis.txt")}"
#}

#resource "local_file" "user_data" {
##  content  = "${data.template_file.user_data.rendered}"
#  filename = "user_data-${sha1(data.template_file.user_data.rendered)}.ps"
#}


resource "aws_iam_role" "ec2-ssm-role" {
  name               = "ec2-ssm-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ssm-instance" {
  role       = aws_iam_role.ec2-ssm-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm-ad" {
  role       = aws_iam_role.ec2-ssm-role.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess"
}

resource "aws_iam_instance_profile" "ec2-ssm-role-profile" {
  name = "ec2-ssm-role-profilee"
  role = aws_iam_role.ec2-ssm-role.name
}



#resource "aws_ssm_document" "ssm_document" {
#  name          = "ssm_document_example.com"
#  document_type = "Command"
#  content       = <<DOC
#{
#    "schemaVersion": "1.0",
#    "description": "Automatic Domain Join Configuration",
#    "runtimeConfig": {
#        "aws:domainJoin": {
#            "properties": {
#                "directoryId": "${aws_directory_service_directory.main.id}",
#                "directoryName": "${aws_directory_service_directory.main.name}",
#                "dnsIpAddresses": ${jsonencode(aws_directory_service_directory.main.dns_ip_addresses)}
#            }
#        }
#    }
#}
#DOC
#}

#resource "aws_ssm_association" "associate_ssm" {
#  name        = aws_ssm_document.ssm_document.name
#  instance_id = aws_instance.win-example.id
##}

data "aws_directory_service_directory" "my_domain_controller" {
  directory_id = "d-92677341ab"
}

resource "aws_ssm_document" "ad-join-domain" {
  name          = "ad-join-domain"
  document_type = "Command"
  content = jsonencode(
    {
      "schemaVersion" = "2.2"
      "description"   = "aws:domainJoin"
      "mainSteps" = [
        {
          "action" = "aws:domainJoin",
          "name"   = "domainJoin",
          "inputs" = {
            "directoryId" : data.aws_directory_service_directory.my_domain_controller.id,
            "directoryName" : data.aws_directory_service_directory.my_domain_controller.name
            "dnsIpAddresses" : sort(data.aws_directory_service_directory.my_domain_controller.dns_ip_addresses)
          }
        }
      ]
    }
  )
}

resource "aws_ssm_association" "windows_server" {
  name = aws_ssm_document.ad-join-domain.name
  targets {
    key    = "InstanceIds"
    values = ["${aws_instance.win-example.id}"]
  }
}

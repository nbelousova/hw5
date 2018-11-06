variable "aws_access_key" {
  default = ""
}

variable "aws_secret_key" {
  default = ""
}

variable "zone_id" {
  type = "string"
  default = "ZUYOKXBWM9MWO"
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-2"
}

variable "domain" {
  type    = "string"
  default = "calc-front"
}

variable "key" {
   type   = "string"
   default= ""
}

variable "sg"{
   type = "list"
   default = [""]
}

resource "aws_instance" "calc_sum"{
  ami             = "ami-0782e9ee97725263d"
  instance_type   = "t2.micro"
  security_groups = ["${var.sg}"]
  key_name        = "${var.key}"
  
  provisioner "local-exec" {
   command = "echo ${aws_instance.calc_sum.public_ip} >> calc-api.hosts && ansible-playbook -i calc-api.hosts calc-sum.yml"
  }

}


resource "aws_instance" "calc_front" {
  ami             = "ami-0782e9ee97725263d"
  instance_type   = "t2.micro"
  security_groups = ["${var.sg}"]
  key_name        = "${var.key}"
  
  provisioner

  provisioner "local-exec" {
    command = "echo ${aws_instance.calc_front.public_ip} >> calc-front.hosts && ansible-playbook -i calc-front.hosts calc-front.yml --extra-vars '{"front_domain":"${var.domain}.nbelousova.devops.srwx.net","api_host":"${aws_instance.calc_sum.private_ip}"}'"
  }
}

resource "aws_route53_record" "calc_front_dns" {
  count   = "1"
  zone_id = "${var.zone_id}"
  name    = "${var.domain}.nbelousova.devops.srwx.net"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.calc_front.public_address}"]
}





variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}


variable "debian_jessie_8_6_ap_northeast_1" {
	default = "ami-1f4a9a7e"
}

variable "aws_nat_ami" { # debian-jessie-amd64-hvm-2016-09-19-ebs
	 default = "ami-9d6c128a" # 

}

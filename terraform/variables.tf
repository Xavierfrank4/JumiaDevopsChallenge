# Project Name
variable "project_name" {
  description = "my project name"
  type        = string
  default     = "jumia"

}
#Count variable
variable "item_count" {
  description = "default count used to set AZs and instances"
  type        = number
  default     = 2
}

#Jumia VPC variables
variable "vpc_cidr" {
  description = "default vpc cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "public_subnet_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "application_subnet_cidr" {
  type    = list(string)
  default = ["10.0.5.0/24", "10.0.6.0/24"]
}

variable "database_subnet_cidr" {
  type    = list(string)
  default = ["10.0.21.0/24", "10.0.22.0/24"]
}

# My Instance variables
# Ubuntu x86 eu_west_2
variable "ami_id" {
  description = "default ami"
  type        = string
  default     = "ami-0f9124f7452cdb2a6"
}

variable "instance_type" {
  description = "default instance type"
  type        = string
  default     = "t2.micro"
}

#AWS Key
variable "aws_key_pair" {
  default = "~/aws/aws_keys/terraform.pem"
}

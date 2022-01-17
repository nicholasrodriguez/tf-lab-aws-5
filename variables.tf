# Lock down to a single resource in SSG while developing
variable "admin_public_ip" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy your instance"
  default     = "eu-west-2"
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "t2.micro"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "jenkins"
  type        = string
}

variable "db_password" {
  description = "Sharayu1707"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "ecommerce-database"
  type        = string
  default     = "ecomdb"
}

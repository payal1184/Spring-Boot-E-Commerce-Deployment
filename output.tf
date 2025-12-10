output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app.public_ip
}

output "rds_endpoint" {
  description = "MySQL RDS endpoint"
  value       = aws_db_instance.mysql.address
}

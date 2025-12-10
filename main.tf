# SECURITY GROUP FOR EC2

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-app-sg"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# SECURITY GROUP FOR RDS

resource "aws_security_group" "rds_sg" {
  name        = "rds-mysql-sg"
  description = "Allow EC2 access to RDS"

  ingress {
    description = "MySQL from EC2"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# EC2 INSTANCE

resource "aws_instance" "app" {
  ami           = "ami-0c2af51e265bd5e0e" # Ubuntu 22.04 (Mumbai)
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "springboot-app"
  }
}

# RDS MYSQL DATABASE

resource "aws_db_instance" "mysql" {
  identifier             = "ecommerce-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20

  username               = "appuser"
  password               = var.db_password
  db_name                = var.db_name

  publicly_accessible    = false
  skip_final_snapshot    = true

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# E-Commerce-Spring-Boot-Application

## Overview

This project demonstrates the deployment of a Spring Boot-based E-Commerce application on AWS EC2 with the backend database hosted on AWS RDS. The infrastructure is provisioned using Terraform, and the CI/CD pipeline is managed with Jenkins.

The application provides typical e-commerce functionalities such as product browsing, cart management, and order processing.

## Fetures 

* User registration and authentication

* Product catalog management

* Shopping cart and checkout functionality

* Order history and management

* Integrated with MySQL RDS database

* CI/CD enabled using Jenkins

## Project Structure

├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── ec2.tf
│   ├── rds.tf
│   ├── security-groups.tf
│   └── user-data.sh
├── jenkins/
│   └── Jenkinsfile
├── src/
│   └── main/
│       └── resources/
│           └── application.properties
└── README.md

## Steps to deploy :

### Step 1 : (Repository)

Clone the repository:

git clone https://github.com/Sharayu1707/E-Commerce-Spring-Boot-Application.git

cd E-Commerce-Spring-Boot-Application

The Maven Spring Boot project is inside the JtProject/ folder.

### Step 2 : (Terraform Setup)

Launch EC2 + RDS 

* provider.tf

provider "aws" {

  region = "ap-south-1"
  
}

* main.tf

######  SECURITY GROUP FOR EC2

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


######  SECURITY GROUP FOR RDS

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


######  EC2 INSTANCE

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

###### RDS MYSQL DATABASE

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

* variable.tf

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

* output.tf

output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app.public_ip
}

output "rds_endpoint" {
  description = "MySQL RDS endpoint"
  value       = aws_db_instance.mysql.address
}

* command

terraform init 
terraform plan 
terraform apply 

### Step 3 : (Configure Spring Boot Application)

* Open src/main/resources/application.properties

* Update database connection with RDS endpoint:

spring.datasource.url=jdbc:mysql://<RDS_ENDPOINT>:3306/ecommerce

spring.datasource.username=<DB_USERNAME>

spring.datasource.password=<DB_PASSWORD>

spring.jpa.hibernate.ddl-auto=update

### Step 4 : (Build the Application)

mvn clean package -DskipTests

This generates the app.war file in the target/ directory.

### Step 5 : (Configure Jenkins Pipeline)

1.Create a new pipeline in Jenkins.

2.Add the following Jenkinsfile to your project:

pipeline {
    agent any

    environment {
        GITHUB_REPO_URL = "https://github.com/Sharayu1707/E-Commerce-Spring-Boot-Application.git"
        GIT_BRANCH = "main"
        SSH_CRED_ID = "jenkins-key"
        EC2_IP = "13.201.47.71"
        REMOTE_USER = "ubuntu"
        APP_PATH = "/opt/ecom-app"
        PROJECT_DIR = "JtProject"
        SERVICE_NAME = "ecom.service"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: "${GITHUB_REPO_URL}", branch: "${GIT_BRANCH}"
            }
        }

        stage('Build with Maven') {
            steps {
                dir("${PROJECT_DIR}") {
                    sh "mvn -B clean package -DskipTests"
                }
            }

            post {
                success {
                    archiveArtifacts artifacts: "${PROJECT_DIR}/target/*.jar", fingerprint: true
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent(credentials: [SSH_CRED_ID]) {
                    script {

                        def jarFile = sh(
                            script: "ls ${PROJECT_DIR}/target/*.jar | head -n 1",
                            returnStdout: true
                        ).trim()

                        if (!jarFile) {
                            error "❌ No JAR file found."
                        }

                        sh "ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${EC2_IP} 'sudo mkdir -p ${APP_PATH}'"

                        sh "scp -o StrictHostKeyChecking=no ${jarFile} ${REMOTE_USER}@${EC2_IP}:${APP_PATH}/app.jar"

                        sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${EC2_IP} '
                            if [ ! -f /etc/systemd/system/${SERVICE_NAME} ]; then
                                echo "[Unit]
                                Description=Spring Boot E-Commerce Application
                                After=network.target

                                [Service]
                                User=${REMOTE_USER}
                                ExecStart=/usr/bin/java -jar ${APP_PATH}/app.jar
                                Restart=always
                                RestartSec=10

                                [Install]
                                WantedBy=multi-user.target" | sudo tee /etc/systemd/system/${SERVICE_NAME}
                                sudo systemctl daemon-reload
                                sudo systemctl enable ${SERVICE_NAME}
                            fi

                            sudo systemctl restart ${SERVICE_NAME}
                        '
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            deleteDir()
        }
    }
}

### Step 6 : (GitHub Webhook Setup)

Go to:

GitHub → Repository → Settings → Webhooks → Add webhook

Payload URL:

http://<JENKINS_URL>/github-webhook/

Event: push

Content type: application/json

### Step 7 : (Deploy the Application)

* Run the Jenkins pipeline.

* After successful deployment, access the application via:

http://<EC2_PUBLIC_IP>:8080

### Outcomes :

* Deployed Spring Boot E-Commerce app on AWS EC2 with RDS MySQL.

* Provisioned infrastructure using Terraform.

* Implemented CI/CD pipeline with Jenkins.

* Configured database connection and application properties for cloud deployment.

* Gained hands-on experience with cloud deployment, automation, and troubleshooting.



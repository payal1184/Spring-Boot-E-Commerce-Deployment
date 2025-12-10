# 🛒 Spring Boot E-Commerce Application  
### Deployment using Terraform, AWS EC2 & RDS

This project demonstrates deploying a **Spring Boot E-Commerce Application** on AWS using **Terraform**.  
The setup includes EC2, RDS, Security Groups, IAM roles, and automated application deployment.

---

## ⚙️ Features

- Spring Boot backend application  
- Terraform-based AWS infrastructure  
- EC2 instance for hosting  
- MySQL RDS database  
- Secure IAM roles & security groups  
- Automated JAR deployment using user_data  
- Production-ready and scalable  

---

## 📦 Tech Stack

- Spring Boot  
- Terraform  
- AWS EC2  
- AWS RDS (MySQL)  
- Amazon Linux 2  
- Maven  
- S3  

---

## 📁 Project Structure

├── src/
│ └── main/
│ └── java/…
│
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ └── user_data.sh
│
├── pom.xml
└── README.md

## 1️⃣ Clone Project
git clone <your-repo-url>
cd SpringBoot-Ecommerce-Cloud

## 2️⃣ Build AWS Infrastructure (Terraform)
AWS Provider
provider "aws" {
  region = "ap-south-1"
}

Infrastructure Includes

EC2 instance with Java runtime

Security Groups for EC2 & RDS

MySQL RDS database

Automated EC2 configuration using user_data.sh

Run Terraform
terraform init
terraform plan
terraform apply

## 3️⃣ Configure Application

Edit the file:

src/main/resources/application.properties

Set database connection
spring.datasource.url=jdbc:mysql://<RDS-ENDPOINT>:3306/ecommerce
spring.datasource.username=<USERNAME>
spring.datasource.password=<PASSWORD>

spring.jpa.hibernate.ddl-auto=update

## 4️⃣ Package the Application

Run Maven:

mvn clean package -DskipTests


Output JAR will appear in:

target/

## 5️⃣ CI/CD Using Jenkins Pipeline

The Jenkins pipeline performs:

✔ Git checkout
✔ Maven build
✔ Copies JAR to EC2
✔ Starts the Spring Boot app using systemd

Pipeline script located in:

jenkins/Jenkinsfile

## 6️⃣ Configure GitHub Webhook

Go to:

GitHub → Repository → Settings → Webhooks → Add webhook

Webhook URL
http://<JENKINS-SERVER>/github-webhook/


Trigger: Push events

## 7️⃣ Access the Application

After successful deployment:

http://<EC2-PUBLIC-IP>:8080

## ✅ Outcomes

- Successfully deployed **Spring Boot E-Commerce application** on AWS EC2  
- **MySQL RDS** database configured and securely connected  
- Complete infrastructure automated using **Terraform**  
- CI/CD pipeline implemented with **Jenkins**  
- Gained hands-on experience in **cloud deployment, automation, and troubleshooting**

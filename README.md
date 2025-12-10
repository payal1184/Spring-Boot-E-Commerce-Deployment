# Spring Boot E-Commerce Cloud Deployment

## Introduction
This project represents a fully automated deployment of a **Spring Boot–based E-Commerce backend** hosted on AWS.  
The application runs on an **EC2 instance**, connects to a **MySQL database on RDS**, and the entire cloud setup is created using **Terraform**.  
A **Jenkins pipeline** is integrated to build, test, and deploy the application automatically.

The goal of this setup is to simulate a real-world cloud production environment for learning DevOps + Cloud deployment practices.

---

## Key Capabilities
- Spring Boot REST API for e-commerce operations  
- JWT-secured user authentication  
- Product and order management modules  
- MySQL database hosted on AWS RDS  
- EC2-based backend deployment  
- Automated provisioning using Terraform  
- CI/CD pipeline implemented using Jenkins  

---

## Repository Layout
├── terraform/
│ ├── main.tf
│ ├── variables.tf
│ ├── outputs.tf
│ ├── ec2.tf
│ ├── rds.tf
│ ├── security-groups.tf
│ └── user-data.sh
│
├── jenkins/
│ └── Jenkinsfile
│
├── src/
│ └── main/
│ └── resources/
│ └── application.properties
│
└── README.md

yaml
Copy code

---

## 1️⃣ Clone Project
```bash
git clone <your-repo-url>
cd SpringBoot-Ecommerce-Cloud
2️⃣ Build AWS Infrastructure (Terraform)
AWS Provider
hcl
Copy code
provider "aws" {
  region = "ap-south-1"
}
Infrastructure Includes:
EC2 instance with Java runtime

Security groups for EC2 & RDS

MySQL RDS database

Automated instance configuration via user_data.sh

Run Terraform
bash
Copy code
terraform init
terraform plan
terraform apply
3️⃣ Configure Application
Edit the following file:

css
Copy code
src/main/resources/application.properties
Set database connection:

properties
Copy code
spring.datasource.url=jdbc:mysql://<RDS-ENDPOINT>:3306/ecommerce
spring.datasource.username=<USERNAME>
spring.datasource.password=<PASSWORD>
spring.jpa.hibernate.ddl-auto=update
4️⃣ Package the Application
Run Maven:

bash
Copy code
mvn clean package -DskipTests
Output JAR will appear inside:

Copy code
target/
5️⃣ CI/CD Using Jenkins Pipeline
The pipeline performs:

✔ Git checkout
✔ Maven build
✔ Copies JAR to EC2
✔ Runs app using systemd service

Pipeline script located in:

Copy code
jenkins/Jenkinsfile
6️⃣ Configure GitHub Webhook
On GitHub:

Settings → Webhooks → Add webhook

Use your Jenkins URL:

perl
Copy code
http://<JENKINS-SERVER>/github-webhook/
Trigger: On Push Events

7️⃣ Access the Application
Once the pipeline finishes, open:

cpp
Copy code
http://<EC2-PUBLIC-IP>:8080
Results & Learnings
Hands-on experience with AWS compute & database services

Automated cloud provisioning using Terraform

CI/CD lifecycle with Jenkins

Full deployment workflow for Spring Boot applications

Strong understanding of security groups, networking and RDS connectivity




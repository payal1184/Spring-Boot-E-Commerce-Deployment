user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y openjdk-11-jre git

    mkdir -p /opt/app
    chown ubuntu:ubuntu /opt/app

    cat <<EOT > /etc/systemd/system/springapp.service
    [Unit]
    Description=Spring Boot Application
    After=network.target

    [Service]
    User=ubuntu
    WorkingDirectory=/opt/app
    ExecStart=/usr/bin/java -jar /opt/app/app.jar
    Restart=always
    RestartSec=10

    [Install]
    WantedBy=multi-user.target
    EOT

    systemctl daemon-reload
    systemctl enable springapp
  EOF
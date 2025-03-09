#!/bin/bash

sudo apt update
sudo apt install openjdk-17-jre wget -y

sudo groupadd kafka-ui
sudo useradd -r -g kafka-ui -s /usr/sbin/nologin kafka-ui

sudo mkdir -p /usr/local/lib/kafka-ui
sudo chown -R kafka-ui:kafka-ui /usr/local/lib/kafka-ui
sudo chmod -R 750 /usr/local/lib/kafka-ui

sudo wget -O /usr/local/lib/kafka-ui/kafka-ui-api-v0.7.2.jar https://github.com/provectus/kafka-ui/releases/download/v0.7.2/kafka-ui-api-v0.7.2.jar
sudo chown kafka-ui:kafka-ui /usr/local/lib/kafka-ui/kafka-ui-api-v0.7.2.jar

# https://github.com/provectus/kafka-ui/blob/master/kafka-ui-api/src/main/resources/application-local.yml файл с конфигами

sudo mkdir -p /etc/kafka-ui
cat << EOF > /etc/kafka-ui/application.yaml
server:
  port: 8080
EOF

sudo chown root:kafka-ui /etc/kafka-ui/application.yaml
sudo chmod 640 /etc/kafka-ui/application.yaml

cat << EOF > /etc/systemd/system/kafka-ui-api.service
[Unit]
Description=Kafka UI API Service
After=network.target

[Service]
User=kafka-ui
Group=kafka-ui

WorkingDirectory=/usr/local/lib/kafka-ui

ExecStart=/usr/bin/java -Dspring.config.additional-location=/etc/kafka-ui/application.yaml --add-opens java.rmi/javax.rmi.ssl=ALL-UNNAMED -jar kafka-ui-api-v0.7.2.jar

Restart=on-failure
RestartSec=10

SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kafka-ui-api.service
sudo systemctl start kafka-ui-api.service

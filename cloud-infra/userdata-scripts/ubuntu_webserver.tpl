#!/bin/bash

set -e

echo "Starting user data script..."

# Ensure /var/log/userdata.log exists and has correct permissions
sudo touch /var/log/userdata.log
sudo chmod 666 /var/log/userdata.log

# Explicitly log each commands output to /var/log/userdata.log and system logger
log() {
  echo "$1" | tee -a /var/log/userdata.log | logger -t userdata -s
}

log "Installing UBUNTU UPDATES, NGINX, and UNZIP..."
sudo apt-get update | tee -a /var/log/userdata.log | logger -t userdata -s
sudo apt-get install -y nginx unzip curl | tee -a /var/log/userdata.log | logger -t userdata -s

log "Installing AWS CLI..."
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" | tee -a /var/log/userdata.log | logger -t userdata -s
sudo unzip -o awscliv2.zip | tee -a /var/log/userdata.log | logger -t userdata -s
sudo ./aws/install | tee -a /var/log/userdata.log | logger -t userdata -s
sudo rm -rf awscliv2.zip aws | tee -a /var/log/userdata.log | logger -t userdata -s

if ! aws --version > /dev/null 2>&1; then
    log "AWS CLI installation failed."
    exit 1
fi

MAX_RETRIES=30
RETRY_COUNT=0
while ! curl -s --head http://169.254.169.254/latest/meta-data/ > /dev/null; do
    log "Waiting for metadata service..."
    sleep 1
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        log "Metadata service unavailable. Exiting."
        exit 1
    fi
done

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)

PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

if [[ -z "$PUBLIC_IP" || "$PUBLIC_IP" == \<\?xml* ]]; then
  PUBLIC_IP="None"
fi

PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
EXECUTION_TIME="$(date '+%Y-%m-%d %H:%M:%S')"
ENVIRONMENT="${environment}" # Dynamically injected by Terraform
LOG_GROUP_NAME="${log_group_name}" # Dynamically injected by Terraform

log "Instance ID: $INSTANCE_ID"
log "Public IP address: $PUBLIC_IP"
log "Private IP address: $PRIVATE_IP"
log "Execution time: $EXECUTION_TIME"
log "Environment: $ENVIRONMENT"
log "LOG GROUP NAME : ${log_group_name}"

echo "<html>
  <body>
    <h1>Welcome to NGINX on EC2</h1>
    <p>Environment: $ENVIRONMENT</p>
    <p>Instance ID: $INSTANCE_ID</p>
    <p>Public IP: $PUBLIC_IP</p>
    <p>Private IP: $PRIVATE_IP</p>
    <p>Execution Time: $EXECUTION_TIME</p>
    <p>Log Group Name: ${log_group_name}</p>
  </body>
</html>" | sudo tee /var/www/html/index.html | logger -t userdata -s


sudo service nginx start || {
  log "Failed to start NGINX."
  exit 1
}

log "Installing CloudWatch Agent..."
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb | tee -a /var/log/userdata.log | logger -t userdata -s
sudo dpkg -i amazon-cloudwatch-agent.deb | tee -a /var/log/userdata.log | logger -t userdata -s
rm amazon-cloudwatch-agent.deb | tee -a /var/log/userdata.log | logger -t userdata -s

sudo tee /opt/aws/amazon-cloudwatch-agent/bin/config.json > /dev/null <<EOF
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/userdata.log",
            "log_group_name": "${log_group_name}",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    },
    "log_stream_name": "{instance_id}"
  }
}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s || {
  log "Failed to start CloudWatch Agent."
  exit 1
}

STATUS_OF_AGENT=$(sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status)
log "CloudWatch Agent status: $STATUS_OF_AGENT"

log "User data script completed."


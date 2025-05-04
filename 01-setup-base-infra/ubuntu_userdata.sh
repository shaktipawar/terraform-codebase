#!/bin/bash
echo "Starting user data script..."

# Redirect all output (stdout and stderr) to a log file
exec > >(tee -a /var/log/userdata.log | logger -t userdata -s 2>/dev/console) 2>&1

# Update and install required packages
# Installs NGINX (web server), unzip (for extracting files), and curl (for making HTTP requests).
echo "Installing UBUNTU UPDATES, NGINX and UNZIP..."
sudo apt-get update
sudo apt-get install -y nginx unzip curl

# Install AWS CLI (official method). Downloads the AWS CLI installer as a zip file.
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws

# Verify AWS CLI installation
AWS_VERSION=$(aws --version)
echo "AWS CLI version: $AWS_VERSION"


# Wait for the metadata service to become available
# Loops until the EC2 instance metadata service becomes available, ensuring that metadata can be fetched.
while ! curl -s --head http://169.254.169.254/latest/meta-data/ > /dev/null; do
    echo "Waiting for metadata service..."
    sleep 1
done

# Fetches a token for the Instance Metadata Service v2 (IMDSv2) with a TTL of 21600 seconds (6 hours).
export TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Retrieves the EC2 instance ID using the metadata service and stores it in the variable INSTANCE_ID.
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance ID: $INSTANCE_ID"

# Retrieves the public IPv4 address of the EC2 instance using the metadata service and stores it in the variable PUBLIC_IP.
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Public IP address: $PUBLIC_IP"
echo "UBUNTU SERVER - NGINX - $PUBLIC_IP" | sudo tee /var/www/html/index.html

# Start the NGINX service
sudo service nginx start
echo "NGINX service started."

# Downloads the CloudWatch Agent installer as a .deb package >> Install >> Cleanup 
echo "Installing CloudWatch Agent..."
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb && sudo dpkg -i amazon-cloudwatch-agent.deb && rm amazon-cloudwatch-agent.deb
echo "CloudWatch Agent installed and Deleted installer."

# Creates the CloudWatch Agent configuration file at `/opt/aws/amazon-cloudwatch-agent/bin/config.json` to collect logs from `/var/log/userdata.log` and send them to the CloudWatch log group `/ec2/terraform-codebase/userdata`.
sudo cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/userdata.log",
            "log_group_name": "/ec2/terraform-codebase/userdata",
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

# Start CloudWatch Agent
START_AGENT=$(sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s)
echo "CloudWatch Agent started with output: $START_AGENT"


echo "Starting CloudWatch Agent..."
STATUS_OF_AGENT=$(sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status)
echo "CloudWatch Agent status: $STATUS_OF_AGENT"

# Log the completion of the script
echo "User data script completed."
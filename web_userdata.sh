#!/bin/bash
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
sudo apt-get update -y
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
sudo apt-get install mysql-client-core-8.0 -y
echo "<h1>Welcome to my Web Application</h1>" | sudo tee /var/www/html/index.html
echo "<p>Instance ID: $INSTANCE_ID </p>" | sudo tee -a /var/www/html/index.html
echo "<p>Availability Zone: $AVAILABILITY_ZONE </p>" | sudo tee -a /var/www/html/index.html
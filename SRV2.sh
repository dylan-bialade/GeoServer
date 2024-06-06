#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install necessary packages
sudo apt-get install unzip
sudo apt install default-jdk 
sudo apt install openssh-server 
sudo apt install apache2 ufw
sudo apt install -y wget vim
sudo apt install postgresql postgresql-contrib
sudo apt-get install sed
# Start and enable SSH
sudo systemctl start ssh
sudo systemctl enable ssh

# Check SSH status
sudo systemctl status ssh

# Add Apache PPA and update
sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt update

# Enable UFW and allow specific IPs
sudo ufw enable
sudo ufw allow from 52.214.221.145
sudo ufw allow from 52.50.207.205
sudo ufw allow from 34.255.188.27
sudo ufw allow from 109.0.28.108
sudo ufw allow from 52.211.149.81
sudo ufw allow from 52.49.122.126
sudo ufw allow from 54.76.16.128
sudo ufw allow from 94.185.65.65
sudo ufw allow from 192.168.0.157


# Configure Apache headers
echo -e "Header set Access-Control-Allow-Origin \"https://apps.sogelink.fr\"\nHeader set Access-Control-Allow-Origin \"https://staging.apps.sogelink.fr\"\nHeader set Access-Control-Allow-Origin \"https://inte.apps.sogelink.fr\"\n" | sudo tee /etc/apache2/conf-available/custom-headers.conf
sudo a2enconf custom-headers
sudo systemctl reload apache2



curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
sed -i.bak -e "s/^#\?listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
sed -i '95 a\host    all             all             0.0.0.0/0               md5' /etc/postgresql/12/main/pg_hba.conf
sed -i '99 a\host    all             all             0.0.0.0/0               md5' /etc/postgresql/12/main/pg_hba.conf
sudo systemctl restart postgresql





# Download and unzip GeoServer
wget https://sourceforge.net/projects/geoserver/files/GeoServer/2.21.0/geoserver-2.21.0-bin.zip
sudo mkdir -p /usr/share/geoserver
sudo unzip -d /usr/share/geoserver/ geoserver-2.21.0-bin.zip

# Create GeoServer user
sudo useradd -m -U -s /bin/false geoserver
sudo chown -R geoserver:geoserver /usr/share/geoserver

# Create GeoServer systemd service
echo -e "[Unit]\nDescription=GeoServer Service\nAfter=network.target\n\n[Service]\nType=simple\nUser=geoserver\nGroup=geoserver\nEnvironment=\"GEOSERVER_HOME=/usr/share/geoserver\"\nExecStart=/usr/share/geoserver/bin/startup.sh\nExecStop=/usr/share/geoserver/bin/shutdown.sh\n\n[Install]\nWantedBy=multi-user.target\n" | sudo tee /etc/systemd/system/geoserver.service

# Reload systemd, enable and start GeoServer
sudo systemctl daemon-reload
sudo systemctl enable --now geoserver

# Check GeoServer status
ss -antpl | grep 8080
sudo systemctl status geoserver

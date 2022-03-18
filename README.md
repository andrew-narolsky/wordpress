# WordPress

## Installation (production)

### Create non-root User

1. Create user and set his password
```
sudo adduser wp --disabled-password
```

2. Add root privileges for user
```
sudo usermod -aG sudo wp
```

3. Copy access key to wp .ssh directory
```
sudo mkdir /home/wp/.ssh
sudo chown wp:wp /home/wp/.ssh
sudo cp .ssh/authorized_keys /home/wp/.ssh/authorized_keys
sudo chown wp:wp /home/wp/.ssh/authorized_keys
```

4. Remove password prompt for wp user (add at the end of file)
```
sudo visudo
----
wp ALL=(ALL) NOPASSWD: ALL
```

5. Login as wp user and edit (add at the top):
```
nano ~/.bashrc
----
cd ~/wordpress/
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
```

### Add swap file

1. Create a 4 Gigabyte file, enabling the swap file, set up the swap space
```
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

2. Make the swap file permanent (add at the end of file)
```
sudo nano /etc/fstab
----
/swapfile   none    swap    sw    0   0
```

3. Tweak your swap settings
```
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50
```

4. Make changes permanent (add at the end of file)
```
sudo nano /etc/sysctl.conf
----
vm.swappiness=10
vm.vfs_cache_pressure = 50
```

### Install Docker and Docker-compose

1. Update packages database
```
sudo apt update
```

2. Add GPG key from official docker repository and add docker repository
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
```

3. Update packages database
```
sudo apt update
```

4. Install docker
```
sudo apt install docker-ce
```

5. Add current user to docker group
```
sudo usermod -aG docker ${USER}
```

6. Restart ssh session

7. Download docker compose
```
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
```

8. Next we'll set the permissions
```
sudo chmod +x /usr/local/bin/docker-compose
```

### Clone this repository

1. Init git settings
```
git config --global user.name "andrew-narolsky"
git config --global alias.up '!git remote update -p; git merge --ff-only @{u}'
```

2. Clone repository
```
git clone https://github.com/andrew-narolsky/wordpress.git
```

### Configure wordpress and docker

1. Copy docker `docker/env-example` to `docker/.env` and change it's variables
```
cd /home/wp/wordpress
cp .env-example .env
```

2. Copy `nginx/sites/site.conf.example-dev` to `nginx/sites/site.conf`
```
cp nginx/sites/site.conf.example-dev nginx/sites/site.conf
```

3. Install make
```
sudo apt install make
```

4. Download wp
```
make wp-install
```

5. Start docker containers
```
make build
```

6. Add executing of containers and the startup
```
sudo crontab -e
---
# Start docker-compose at boot
@reboot cd /home/wp/wordpress/ && /usr/local/bin/docker-compose up -d
```

7. Go to the site and install WordPress

### Configure SSL from Let's Encrypt

1. Install Let's Encrypt Client
```
# Ubuntu 18.04
sudo apt-get update && sudo apt-get install software-properties-common
sudo add-apt-repository universe && sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update && sudo apt-get install certbot python-certbot-nginx

# Ubuntu 20.04
sudo apt-get install letsencrypt
```
2. Get SSL certificates (change example.com to current domain)
```
sudo certbot certonly -a webroot --webroot-path=/home/wp/wordpress/html/ -d EXAMPLE.com -d www.EXAMPLE.com
```

3. Generate Strong Diffie-Hellman Group
```
mkdir /home/wp/wordpress/letsencrypt/
sudo openssl dhparam -out /home/wp/wordpress/letsencrypt/dhparam.pem 2048
```

4. Copy certificate files to local directory (change example.com to current domain)
```
sudo cp /etc/letsencrypt/live/EXAMPLE.com/fullchain.pem /home/wp/wordpress/letsencrypt/fullchain.pem
sudo cp /etc/letsencrypt/live/EXAMPLE.com/privkey.pem /home/wp/wordpress/letsencrypt/privkey.pem
```

5. Copy settings from `nginx/sites/site.conf.example-prod-ssl` to `nginx/sites/site.conf` and change `example.com` to current domain name
```
cd /home/wp/wordpress
rm nginx/sites/site.conf
cp nginx/sites/site.conf.example-prod-ssl nginx/sites/site.conf
nano nginx/sites/site.conf
```

6. Restart nginx container
```
cd /home/wp/wordpress/ 
docker-compose restart wp_nginx
```

7. Set up auto renewal (change EXAMPLE.com to current domain)
```
sudo crontab -e
---
# Copy certificate files to local directory
49 2 * * 1 cp /etc/letsencrypt/live/EXAMPLE.com/fullchain.pem /home/wp/wordpress/letsencrypt/fullchain.pem
49 2 * * 1 cp /etc/letsencrypt/live/EXAMPLE.com/privkey.pem /home/wp/wordpress/letsencrypt/privkey.pem

# Restart nginx
50 2 * * 1 cd /home/wp/wordpress/ && /usr/local/bin/docker-compose restart wp_nginx
```
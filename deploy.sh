#!/usr/bin/env bash
# File: deploy.sh

set -x

function updateUbuntu {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< RUN UBUNTU UPDATE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install update
  export LC_ALL=C.UTF-8
  export LANG=C.UTF-8
  echo ""
}
function installNodejs {
  echo " <<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NODEJS WITH NVM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
  sudo apt-get install -y nodejs
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<< NODE INSTALLATION COMPLETED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}


function cloneApp {
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< CLONE REPOSITORY TO BE DEPLOYED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  if [[ -d Events-Manager/ ]] # check ifthere is a previous clone, remove it before cloning the repo
  then 
    sudo rm -rf Events-Manager/
  fi
  sudo git clone https://github.com/iidrees/Events-Manager.git
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SEE CONTENT OF REPOSITORY >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  cd Events-Manager
  sudo git checkout chore/deploy-on-aws/158841810
  ls -a
  echo ""
}


function setupAppEnv {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ADD VALUES TO THE .env FILE  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # store the values below in the .env file that 
  # would make the variables available in the node environment
  sudo bash -c 'cat > .env <<EOF
  SECRET=< JWT SECRET >
  PORT=<APP PORT NO>
  DATABASE_URL=< DATABASE URL >
  CLOUDINARY_URL=< CLOUDINARY URL >
  UPLOAD_PRESET=<CLOUDINARY UPLOAD_PRESET>
  SEED_ADMIN_PW=<ADMIN_TEST PW>
  SEED_SUPERADMIN=<PASSWORD FOR SUPERADMIN>
  SEED_ADMIN=<SEED ADMIN PW>
  SEED_USER=<SEED USER PW>
  EMAIL=<NODE_MAILER EMAIL SETUP>
  PASSWORD=<PW_FOR_EMAIL>
EOF'
}


function setupPm2 {
  # setup background process runner for nodejs so pm2 is installed globally
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<< INSTALL PM2 TO RUN BACKGROUND PROCESSES >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo npm install -g pm2
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<< PM2 SUCCESSFULLY INSTALLED >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}



echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SETUP NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

function setupNginx {
  echo ""
  # Setup nginx by installing the nginx package
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL NGINX >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  sudo apt-get install nginx -y
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< SETUP NGINX CONFIGURATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # check if the default or previous config exists and remove same 
  # before creating a fresh nginx config
  sudo rm -rf /etc/nginx/sites-enabled/default
  if [[ -d /etc/nginx/sites-enabled/nginx-router ]]
  then
    sudo rm -rf /etc/nginx/sites-enabled/nginx-router
    sudo rm -rf /etc/nginx/sites-available/nginx-router
  fi
    sudo bash -c 'cat > /etc/nginx/sites-available/nginx-router <<EOF
    server {
    listen 80;
    server_name example.com www.example.com;
    location / {
      proxy_pass        http://127.0.0.1:5050;
    }
  }
EOF'
  # when the config file is created a symlink is made here between two dir
  sudo ln -sfn /etc/nginx/sites-available/nginx-router /etc/nginx/sites-enabled/nginx-router
  echo ""
  sudo service nginx restart
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<< NGINX CONFIGURATION DONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

function startApp {
  echo "<<<<<<<<<<<<<<<<<<<< INSTALL DEPENDENCIES & START APPLICATION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # Install npm modules and dependencies application needs
  sudo npm install --unsafe-perm
  NODE_ENV=production npm run seq:db # Run database migratrion in production
  sudo npm run build # build application 
  sudo pm2 start npm -- start # start application pm2
  echo "<<<<<<<<<<<<<<<<<<<<<< APPLICATION STARTED ON THE EC2 INSTANCE >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
}

function runSSLSetup {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<< INSTALL > CONFIGURE SSL >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo ""
  # install packages for the setup and config of the SSL certificate
  sudo apt-get update
  sudo apt-get install software-properties-common
  sudo add-apt-repository ppa:certbot/certbot
  sudo apt-get update
  sudo apt-get install python-certbot-nginx
  sudo certbot --nginx # begins the configuration of the SSL
  echo ""
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<< SSL CERTIFICATE CONFIGURATION DONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
}

echo "<<<<<<<<<<<<<<<<<<<<<<<< APPLICATION SUCCESSFULLY DEPLOYED ON AWS >>>>>>>>>>>>>>>>>>>>>>>>>>>"


# script is run by this main function
function main {
  updateUbuntu
  installNodejs
  cloneApp
  setupAppEnv
  setupPm2
  setupNginx
  startApp
  runSSLSetup
}

main



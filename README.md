# DEPLOY WITH BASH SCRIPT

#### THIS IS AN AUTOMATED DEPLOYMENT OF A NODE APPLICATION ON AWS USING BASH SCRIPT

##### For successful deployment script, please manually add the environment variables and domain names in the deploy.sh file.

##### To add the correct env variables look for this function on lines 36 - 53 :

```
function setupAppEnv {
  echo "<<<<<<<<<<<<<<<<<<<<<<<<< CREATE .env FILE  >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  # store the values below in the .env file that would make the variables available in the node environment

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
```

##### NOTE: only the values in the EOF token should be changed for example SECRET=< JWT SECRET > should be SECRET=herokubuild

#### Ensure to change the values on the left side of the variable to the correct value.

#### Also endevour to create your domain name and ensure that you have made the necessary configuration on AWS Route 53

#### after configuration please change line 85 the "server_name example.com www.example.com" with your own domain name.

#### Please only change the domain name

#### save the file and then run either of this commands

```
1. sudo bash deploy.sh
2. sudo chmod +x deploy.sh && ./deploy.sh
```

# DEPLOY CP WITH BASH SCRIPT

## This Is An Automated Deployment of A Nodejs Application on AWS Using Bash Script

This guide assumes that you already have an AWS account and can easily follow the steps below however if you do not already have an account, go to [https://aws.amazon.com](), create an account and then jump into the steps highlighted below.
If you already have an account, please just dive in.

### How To Setup AWS **EC2** Instance and Deploy the Application

##### First Create an Instance on **EC2** on AWS

Creating an AWS Ubuntu instance that would serve as the production environment where my application would be hosted from and the following steps are the ways that can be taken in creating an AWS instance.

1.  At the top-left side of the screen / navigation bar, you would see a **Services** option, which you should click for a drop down of more options.
2.  after clicking **Services** and in the drop down of options, look for the the compute heading, under which you would find option **EC2**.
3.  Click on the **EC2** option to get access to the **EC2** **Dashboard** where different information about your **EC2** resources are displayed.
4.  On this **EC2** **Dashboard** page, there are different headings, please look for a **Create Instance** blue button and click on that to begin the process/steps in creating a new instance.
5.  When you click the blue button above in step 4, you see a page asking you to choose an **Amazon Linux Image (AMI)** which is like a preconfigured operating system that would host the application that is to be deployed and hosted on it. And AMIs are popularly called **Instances**.
6.  On the AMI page, look for the **Ubuntu Server 16.04 LTS (HVM), SSD Volume Type** at the extreme right of which you would see a blue select button. Click the button.
7.  The next steps requires that you pick the type of instance you would like the Ubuntu server you in step 6 to be like for example, how many CPU would you like, what memory size would you love etc. however for this exercise we are not deploying a large scale application so we would be using an instance with the **Free Eligible Tier** badge on it i.e. a t2.micro.
8.  After step 7 above, click next button beside the Review and Launch button until you see a Configure Security Group page which is where you control the type of general or specific internet traffic access to your instance. For this instance we are going to set some rules by first choosing the Create a new Security group option and then below that you will see a Add Rule button with the SSH rule already configured above it. The following 4 rules are then added to that configured:
    > - HTTP with port of 80
    > - HTTPS with port 443
    > - POSTGRESQL with port 5432

**NOTE** that the IP for each of these rules are set under source, however for this exercise you can leave the **source** option at **custom** and **IP** as **0.0.0.0/0. However you should take the time to also read up on how for example ensure that your SSH traffic is from your one IP address and not from the whole world.**

9.  After step 8 is done , please click Review and Launch blue button to complete the process so that the instance can be setup, configured and ready to use.
    After following these steps you should have successfully created an **EC2** instance on Amazon Web **Services**.

##### Second Get a Domain Name and Link it to Route 53

To get a domain name you can check **GoDaddy** or even **Amazon Web Services** for paid domain names, but for this exercise you can get either paid or free domain names from this website Freenom [http://www.freenom.com/en/index.html?lang=en]().
So get a free domain name and then head to AWS Route 53 page to link the AWS IP to the domain name you got from freedom.
Its is important to not that what Route 53 does is to map domain names to the AWS IP address where your application would be hosted on when running on the instance just launched.
Follow the following steps to configure the linking up of the AWS **EC2** IP to the domain name you created:

1.  Go to [https://console.aws.amazon.com/route53/home?]()
2.  Under the **DNS MANAGEMENT** heading, click on the **Get started now** button to create a **Hosted Zone**
3.  On the next page, click on the **Create Hosted Zone** button and then input the domain name (from [freenom.com]() or some other domain name websites) in this format **example.com** then click create.
4.  Next step is to create a record set for that domain name you just added in step 3 by doing the following:
    > a. In the name field add www in order to make the address www.example.com
    >
    > b. In the type field, click on the drop down to pick a type A IPv4 address
    > in the values field, copy the IPv4 Public IP address from your instance details page and paste it in the value field here
    >
    > c. Save this record set by clicking the create button and you are good to go.

**NOTE. when pointing your AWS DNS to your domain name its important to create an Elastic IP for that instance and then asscoitate that instance to that Elastic IP, failure of which would lead to AWS charging you ($$) for things you did not plan to or should necessarily not pay for.**

The linking up is important in order to allow ur have a valid domain name for our NGINX configuration and also our SSL certificate configuration. Without a domain name for the our SSL config to map to, it would not be completely easy to get SSL certificate for our domain name.

Since we cannot just create a domain name and point our instance’s IP address to it using Route 53 without deploying or hosting an application there.  The following are the steps you can follow to deploy a Nodejs application that was a product I built few months back
So the next step now is to access the instance we just created through the command line / terminal using **SSH**.

# Installation and Deployment

After Ubuntu is updated and NodeJs is installed, the script will also installs pm2 Nginx, and certbot.
Ubuntu is updated in order to make new packages available to to the OS for use.
NodeJs version 8.x is installed because it has the stable version of `npm` the application was built with. And in order to be consistent so there would be no bugs encountered when the applicatoin is run with another `nodejs` version, I chose to stick with what works for now.
Nginx is installed as a reverse proxy service that allows our application though
being served on port e.g 3000 to be accessible to the outside world on the HTTP /HTTPS
Port of 80 / 443 respectively. So Nginx abstract out our port and protects it from the outside world
For those interested in knowing how to setup SSL in their application, check the certbot [https://certbot.eff.org/lets-encrypt/ubuntuxenial-nginx]() and [letsencrypt.org](https://letsencrypt.org/) for more information.

## Configure Instance Using Command line / Terminal

Below is a step by step guide on how to **connect** to the instance using the command line and then running the script

1.  From the \***\*Services\*\*** drop down menu at the navigation bar, click on the **EC2** option then on the **EC2** **Dashboard**, under the Resources heading click on the Running Instances highlighted link.
2.  On the page showing your instances, locate the instance created previously and then pick the instance
3.  At the top of the page there should be \***\*connect\*\*** button, click on that button and follow the instruction on how to **connect** to the instance through the command line or terminal

After you have successfully connected to the instance through the terminal, the next step the following:

1.  Clone the repository where the bash script automating deployment is
2.  change directory into the cloned repository with the command `cd DevOps-09-Auto-Deploy`
3.  Change the script deploy.sh permission and make it executable running the command `chmod +x deploy.sh`
4.  before the script is executed the deploy.sh script must be edited and update to store the correct environment variables and to also replace the example.com domain names currently present there with the one that was created in the previous section.
5.  To add the correct env variables look for this function on lines 36 - 53 :

    ```
    function setupAppEnv {
      echo "<<<<<<<<<<<<<<<<<<<<<<<<< CREATE .env FILE  >>>>>>>>>>>>>>>>>>>>>>>>>>>>"
      # store the values below in the .env file that would
      # make the variables available in the node environment

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

    > only the values in the EOF token should be changed for example SECRET=< JWT SECRET > should be SECRET=herokubuild
    > Ensure to change the values on the right side of the variable to the correct value.

6.  After step 4 is done through this command `sudo nano deploy.sh` and after edits are made the file should be saved with the command `ctrl + o` and the editor be exited with `ctrl + x`.
7.  To execute the script, run `./deploy.sh` in the terminal or just run the command `sudo bash deploy.sh`

## NOTE:

For successful deployment, please manually add the environment variables to the section highlighted above and also add the domain names in the `deploy.sh` file.

Also endevour to create your domain name and ensure that you have made the necessary configuration on AWS Route 53

After configuration please change line 94 the `server_name example.com www.example.com` with your own domain name.

In this lab, we will cover 3 objectives. Log into the Azure portal and configure the Cloud Shell to use Bash. 2nd, 
check the version of Terraform the Cloud Shell is running. If not the latest version,
we will update it. Last objective, configure Terraform to use the Terraform Azure provider.

#Check the Terraform version:
terraform version

#If needed, update the Terraform version by downloading the Linux Amd64 binary from the Download CLI section of the Terraform website
#and following the steps below. This can be done by right-clicking on the binary and clicking Copy Link Address:
#Back in the Cloud Shell, download the zip file using curl:
curl -O https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip

#Verify the zip file downloaded successfully:
ls 

#Unzip the file:
unzip terraform_1.1.7_linux_amd64.zip
#List the files again and verify the Terraform binary was unzipped:
ls

#Make a new directory named bin:
mkdir bin

#Move the Terraform binary to the bin directory:
mv terraform bin/

#List the files again and verify the binary was moved successfully:
ls
ls bin/

#Restart the Cloud Shell and verify the new verion of Terraform:
terraform version
Set Up the Working Directory
#Make a new directory called terraformguru:
mkdir terraformguru

#Change to the new directory:
cd terraformguru

#Create a new file called providers.tf and paste in the following code (to create a file you can use nano/ vim ):
terraform {
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "=2.91.0"
        }
      }
    }

    provider "azurerm" {
      features {}
      skip_provider_registration = true
    }
#Save and quit the file:
ESC
:wq!

#Check the formatting of the file:
terraform fmt

#Initialize the working directory:
terraform init
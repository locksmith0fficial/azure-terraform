Set Up the Cloud Shell and Lab Environment

#In the Azure portal, click on the Cloud Shell icon (>_) at the top of the page, to the right of the search bar.
Select Bash.
Click Show advanced settings.
For the Cloud Shell region, select the same region as your resource group location (This will be noted above, in the portal).
For Storage account, choose Use existing.
Under File share, select Create new and type in the name of terraform.
Click Create storage. Your Cloud Shell should begin to configure.

#command to pull down the lab setup script from the GitHub repo:
    wget https://raw.githubusercontent.com/ACloudGuru/advanced-terraform-with-azure/main/lab_aks_cluster/lab_7_setup.sh

#Run follwing cmd to list the contents.
    ls 

#You should see the lab setup script listed, lab_7_setup.sh.
#Run to make it executable.
     chmod +x lab_7_setup.sh  

#Run the script: 
     ./lab_7_setup.sh

#Run following cmd to list the contents.
     ls 

#You should see a terraformguru directory listed.

#Run to change into that directory.
    cd terraformguru/ 

#List the contents
#You should see one configuration file listed: providers.tf.

#Run to take a look at the file.
     vim providers.tf 

#Type folling cmd to quit out of the file.
     Esc :q 

**Import the Resource Group
#Run the following cmd to initialize the working directory.
     terraform init 

#run following to look up the subscription ID.
    az group list 

#Copy the subscription ID to your clipboard. It should be located on the top line after "id":.
#Make sure to copy all of the characters in between the quotation marks.
#Run the following command, making sure to paste in your copied subscription ID to replace <SUBSCRIPTION_ID>:
    terraform import azurerm_resource_group.k8s <SUBSCRIPTION_ID>

#Run the following cmd to edit the file.
    vim providers.tf 

#Delete the comment hashes (#) in front of name and location.
#Replace the placeholder <RESOURCE_GROUP_NAME> next to name.
#Copy the resource group name located at the top left of the Azure portal, under Home.
#Paste it into the file, to replace <RESOURCE_GROUP_NAME> making sure not to replace the quotation marks.
#Replace the placeholder <RESOURCE_GROUP_LOCATION> next to location.

#Copy the resource group location listed to the right of Location in the Azure portal.
#Paste it into the file, to replace <RESOURCE_GROUP_LOCATION> 
#Type Esc followed by :wq to save and quit the file.

#Run the following command to create an SSH key:
ssh-keygen -m PEM -t rsa -b 4096

#Hit Enter to keep the defaults.
#Hit Enter to leave the passphrase empty.
#Hit Enter again to create your key pair.

*Add the AKS Config, Variables, and Outputs to the Configuration
#Run to create your first configuration file.
vim aks.tf 

#Enter the following configuration:
resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix

    linux_profile {
        admin_username = "ubuntu"
        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = var.agent_count
        vm_size         = "Standard_D2s_v3"
        os_disk_size_gb = 30
    }

    service_principal {
        client_id     = var.aks_service_principal_app_id
        client_secret = var.aks_service_principal_client_secret
    }

      network_profile {
         load_balancer_sku = "Standard"
         network_plugin = "kubenet"
     }

        tags = {
          Environment = "Development"
        }
    }

#Type Esc followed by :wq to save and quit the file.
#Run to create your next configuration file.
    vim variables.tf 

#Enter the following configuration. Be sure to replace <YOUR_RESOURCE_GROUP_LOCATION> with the location of your resource group, and replace <SERVICE_PRINCIPAL_APP_ID> and <SERVICE_PRINCIPAL_CLIENT_SECRET> with the service principal IDs generated for this lab, which can be found in the lab credentials section.
    variable "resource_group_location" {
        default = "<YOUR_RESOURCE_GROUP_LOCATION>"
    }

    variable "agent_count" {
        default = 3
    }

    variable "ssh_public_key" {
     default = "~/.ssh/id_rsa.pub"
    }

    variable "dns_prefix" {
        default = "k8sguru"
    }

    variable cluster_name {
      default = "k8sguru"
    }

    variable aks_service_principal_app_id {
        default = "<SERVICE_PRINCIPAL_APP_ID>"
    }

    variable aks_service_principal_client_secret {
        default = "<SERVICE_PRINCIPAL_CLIENT_SECRET>"
    }

#Type Esc followed by :wq to save and quit the file.
#Run to create your final configuration file.
    : vim output.tf 

#Enter the following configuration:
    output "resource_group_name" {
        value = azurerm_resource_group.k8s.name
    }

    output "client_key" {
        value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_key
    }

    output "client_certificate" {
        value = azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate
    }

    output "cluster_ca_certificate" {
        value = azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate
    }

    output "cluster_username" {
     value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
    }

    output "cluster_password" {
        value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
    }

    output "kube_config" {
        value = azurerm_kubernetes_cluster.k8s.kube_config_raw
        sensitive = true
    }

    output "host" {
        value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
    }

#Type Esc followed by :wq to save and quit the file.

*Deploy and Verify the Kubernetes Cluster is Running
#Run "terraform fmt" to check the formatting of your configuration files.
#Your aks.tf, output.tf, providers.tf, and variables.tf files should be listed.

#To validate the code in your configuration files Run
    terraform validate 

#You should see a message confirming that your configuration is valid.

#to create your execution plan Run.
 terraform plan -out aks.tfplan 
 

#to execute your execution plan Run 
    terraform apply aks.tfplan 


#You will see a big block of text appear= cluster deployed successfully. You can scroll up to view the Apply complete message in green to confirm.
#Scrolling down from the Apply complete message, you can view the client_certificate, client_key, cluster_ca_certificate, cluster_password, and cluster_username. 
#Lastly, you should see the host address, kube_config, and resource_group_name.

#to move your kube_config to a different file Run the following command :
    echo "$(terraform output kube_config)" > ./azurek8s
    cat ./azurek8s #to check the file.

#You should see EOT at the beginning and end of the file, which will need to be removed.

#to edit the file Run 
    vim ./azurek8s 

#Delete the <<EOT at the beginning and the EOT at the end of the file.
#save and quit the file.

#to create your environment variable Run 
    export KUBECONFIG=./azurek8s 

#to check if your nodes are running and healthy Run 
    kubectl get nodes 
#You should see your 3 nodes returned with a STATUS of Ready.
# Terraform multi-modules deployment

### The provisioned resources:

**This Terraform manifest is going to provision the below infrastructure resources:**

**AWS VPC:**
* New VPC
* Three Private subnets
* Three Public subnets
* Three route tables, and routes for the Public subnets
* Three route tables, and routes for the Private subnets
* Internet Gateway to be attached to the Route table of the public subnets
* Three NAT Gateways to allow private resources reach the internet and acquire updates
* Three Elastic IPs for the NAT gateways
* The route between the private RT and the NAT Gateway


**AWS EC2:**
* Bastion Host EC2 instance for connecting to private AWS resources
* Jenkins EC2 instance for CI/CD pipelines
* Jenkins install and configure script that will be executed in the instance user-data
* Security groups to allow the needed traffic for both instances (such as 22 and 443)
* IAM instance profile for Jenkins server
* Key Pair for each instance, and save its public/private parts in AWS SSM parameter store

**AWS RDS:**
* RDS Amazon Aurora Cluster with PostgreSQL compatibility, that has the below specs:
	Postgres version 12.4
	Auto minor version upgrade
	Provisioned engine mode
	Encrypted storage
	Backup retention period of 30 days
	Enable deletion protection
	Preferred backup and maintenance windows
Not publicly accessible
* Random string for the Admin password, and save it in AWS SSM parameter store
* Security groups to allow the needed traffic from the VPC CIDR range (5432)

**AWS EKS:**
* Amazon EKS cluster and nodes using the official EKS community module with the latest stable version, that has the below specs:
	Amazon EKS version 1.19
	Disable Public access
	 Cluster log retention for 30 days
	EKS node group with min, max and desired capacities.
* Security groups to allow the needed traffic between nodes and master, and the secure connection to the master
* IAM roles for both master and worker nodes

### Terraform structure:
* This manifest is structured by using different modules that are defined in the ```main.tf``` that's in the root of the repo.
* all the modules are defined inside modules directory, and referenced in the ```main.tf``` file like this: 
``` bash
module "vpc" {
  source = "./modules/vpc"
````
* The common variables are defined in the ```variables.tf``` file in the root, while each module specific variables are defined in each module's directory
* Some resources are referenced from one module to another by usig the outputs in the source module, and define them as variables in the target module, for example:
  *  The VPC Id is set as an output in the vpc module.
  ```
  output "vpc_id" {
  value = aws_vpc.vpc.id
  }
  ```
  *  Then it can be called in the ec2 module by setting the below:
  ```
  vpc_id = module.vpc.vpc_id
  ```
  *  And then, we set the vpc_id as a variable in the ec2 module's ```variables.tf```



### Terraform backend and providers:
* The backend is configured to save the state in an S3 bucket called: ```challenge-task-terraform-state-us-east-1```, under a key called: ```tf_task.tfstate```. And use DynamoDB to lock the state in a table called: ```terraform_state```
* Terraform templates are developed based on TF version ```0.15.0```, and AWS provider higher than ```v3.39```
* Other providers are defined in their corresponding module, for example the TLS provider is defined in the ec2/eks modules to create a Key pair


### How to run the manifest:
For linting, we have to iterate over modules' directores to check the format of each one:
**liniting:**
``` bash
modules_dir="./modules"
modules=$(ls ${modules_dir})

for module in $modules; do
    module_dir="${modules_dir}/${module}"
    pushd ${module_dir}
    terraform fmt -check -diff
	popd
done
```

**validate the TF manifest:**
``` bash
terraform init \
    -input=false \
    -backend=true \
    -backend-config="bucket=challenge-task-terraform-state-us-east-1" \
    -backend-config="region=us-east-1" \
    -backend-config="encrypt=true" \
    -backend-config="dynamodb_table=terraform_state"
```
``` bash
terraform validate
```

**Planning the TF manifest:**
``` bash
terraform plan \
	-input=false \
	-out="./terraform_plan.tfplan"
```
**Apply the deploy the planned resources**
``` bash
terraform apply
```


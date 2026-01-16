# IaC --- Using Terraform to deploy infrastructure to Google Cloud


This is a demo project for maintaining and deploying *InfrastructureAsCode(IAC)* to Google Cloud Platform. 
Terraform provides a standard way to build infrastructure by using declarative code.



The following resources as used in this project
- Google Cloud Function
- Firestore to host user count



### Steps to IaC
- Run `terraform init` to initialize the terraform project
- Run `terraform fmt` to format and validate the terraform code


### Using Modules in Terraform

Modules help to group resources into different categories. In this sample, the following modules are used:
- Compute
- Networking 
- Storage
- Iam

Each module can then be executed by itself using the module flag: `terraform apply -module="module_name"`

The plan command comes in handy to check what gets executed before making the change to the infrastructure. 
`terraform plan`

Also, the `out` option can be provided to the plan function to save the output of the plan command into a file. This file can later be referenced by he `apply` command with the output file as a command
Eg: `terraform apply output`



### Insights
All the resources need to be enabled first
The plan command is a nice way to first visualize what is being created, so as to not have any surprises
The python code is also hashed, and redeployed if changes are detected
The fact that this does not require any user input through the GUI and can
be managed entirely through a shell means its a good candidate to setup through a CI/CD pipeline

The function is not being updated with the 
# IaC --- Using Terraform to deploy infrastructure to Google Cloud


This is a demo project for maintaining and deploying *InfrastructureAsCode(IAC)* to Google Cloud Platform. 
Terraform provides a standard way to build infrastructure by using declarative code.

## Architecture Overview
This project deploys a serverless web application on the Google Cloud Platform. It shows a greeting based on the name of the user and records the number of visits for each user to the site in a firestore database.
This project is deployed using Terraform

**Example:**
- First Visit  : "Hello! John!.You have visited 1 times!"
- Second Visit : "Hello! John!.You have visited 2 times!"

### Architecture Components 
1. **Frontend (Cloud Run)**
- A static web page with a form where user enter their name and see the greeting message
- HTML/CSS/Javascript asset being served through an NGINX Container

2. **Backend API (Cloud Function)**
- A Python(3.10) Cloud function that receives the request from the frontend service, fetches the count from firestore database, increments the count and updates in the database
- Returns greeting message and visit count

3. **Database (Firestore)**
- Firestore database to store visit count records
- *greetings* collection for each name

4. **Object Storage**
- Stores the function code zip file for deployment to Cloud Function
- Terraform state bucket stores each state change from terraform

5. **IAM Security**
- Service accounts for cloud function and cloud run services
- Operated with least privilege principle

6. **VPC Networking**
- VPC Network within GCP cluster
- Serverless Connector
- Firewall rules for network access control

7. **Infrastructure as Code (IaC)**
- Infrastructure defined using Terraform
- Automated deployments
- Version controlled


## Terraform Modules

1. **Compute Module**
- Cloud function deployment
- Cloud run service deployment
 
2. **Storage Modules**
- Cloud store buckets
- Firestore database management

3. **IAM Module**
- Service Account definitions
- IAM Policies

4. **Networking Module**
- VPC Network
- Serverless Connector
- Firewall rules



### **Request flow**
1. User enters name in frontend form
2. JavaScript makes HTTP GET request to Cloud Function URL
3. Cloud Function receives request with `?name=John` parameter
4. Function queries Firestore for existing count
5. Function increments count or stores 1 for first time visit
6. Function saves new count to Firestore
7. Function returns JSON: `{"greeting": "Hello! John!", "count": 3}`
8. Frontend displays greeting to the user

### Steps to IaC
1. **Initialize Terraform**
```sh
   terraform init
```
2. **Plan Infrastructure to output**
```sh
   terraform plan -out=output/plan
```
3. **Deploy Terraform**
```sh
   terraform apply output/plan 
```
4. **Access Application**
 - Frontend Url: URL to access the frontend website `terraform output cloudrun_url`
 - API Url: URL for the cloud function API `terraform output function_url`
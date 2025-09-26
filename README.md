# Three-Tier Application on AWS

This repo provides a **hands-on guide to deploy a three-tier application on AWS**. It covers:

* **Network Layer:** VPC, public & private subnets, route tables.
* **Application Layer:** Flask backend on EC2 with Load Balancer & Auto Scaling.
* **Data Layer:** RDS MySQL for structured data, DynamoDB for metadata.
* **Storage & Notifications:** S3 for files, SNS for notifications.
* **Secure Access:** IAM roles and Bastion Host.

By following this repo, you’ll learn how to **build, deploy, and scale a complete three-tier application on AWS**.

---


## Table of Contents
- [Part 1: Network Setup](#part-1-network-setup)
- [Part 2: Set Up RDS](#part-2-set-up-rds)
- [Part 3: Set Up S3](#part-3-set-up-s3)
- [Part 4: Configure SNS to Send Email Notifications on S3 File Uploads](#part-4-configure-sns-to-send-email-notifications-on-s3-file-uploads)
- [Part 5: Create DynamoDB Table and Lambda for File Metadata Extraction & Storage](#part-5-create-dynamodb-table-and-lambda-for-file-metadata-extraction--storage)
- [Part 6: Deploy a Flask Application on Test AMI Builder EC2 with RDS & S3, DynamoDB Integration in Public Subnet](#part-6-deploy-a-flask-application-on-test-ami-builder-ec2-with-rds--s3-dynamodb-integration-in-public-subnet)
- [Part 7: Create an AMI, Launch Template, and Auto Scaling Group](#part-7-create-an-ami-launch-template-and-auto-scaling-group)
- [Part 8: Attach Load Balancer to Auto Scaling Group (ASG)](#part-8-attach-load-balancer-to-auto-scaling-group-asg)
- [Part 9: Create a Bastion Host in Public Subnet to Access Instances in Private Subnet](#part-9-create-a-bastion-host-in-public-subnet-to-access-instances-in-private-subnet)
- [Part 10: Connect From Bastion Host to Private Instance](#part-10-connect-from-bastion-host-to-private-instance)
- [Part 11: Cleanup – Terminate All Resources](#part-11-cleanup--terminate-all-resources)
---

## Part 1: Network Setup

<details>
<summary>📖 Theory: Understanding the Network Setup</summary>

In this section, we set up the foundation of the three-tier architecture on AWS:

VPC: Isolated network for your application.

Subnets: Separate public subnets for Load Balancers and NAT, and private subnets for app and database layers.

Internet Gateway & NAT Gateways: Enable internet access for public and private resources.

Route Tables: Proper routing for public and private subnets to ensure secure and controlled traffic flow.

By completing this step, your AWS environment will be ready to deploy the application and database layers securely.

Theory: Understanding the Network Setup
The network setup is the most crucial part of any cloud application. Think of the VPC (Virtual Private Cloud) as your own virtual data center within AWS, completely isolated from other networks. The VPC provides a secure, private space where you can define and control your network environment.

Within the VPC, we create subnets to logically partition the network. This is a core security practice. Public subnets contain resources that must be accessible from the public internet, such as a load balancer or a bastion host. They get their internet access via the Internet Gateway (IGW). In contrast, private subnets host sensitive resources like application servers and databases. These resources cannot be directly reached from the internet, which drastically reduces their attack surface.

To allow instances in private subnets to access the internet for things like software updates or patching, we use a NAT Gateway (Network Address Translation). The NAT Gateway allows outbound traffic to the internet but prevents any inbound connections initiated from the outside.

Finally, Route Tables act as the rules for each subnet, dictating where network traffic is directed. Public subnets have a route table that points to the Internet Gateway, while private subnets have a route table that points to the NAT Gateway. This careful routing ensures all traffic flows securely and according to your design.

</details>

### 1. Create a VPC
1. Go to **AWS Console → VPC Dashboard**.  
2. Click **Create VPC**.  
3. Enter:  
   - **Name:** `demo-app-vpc`  
   - **IPv4 CIDR Block:** `10.0.0.0/16`  
4. Click **Create VPC**.

### 2. Create Public & Private Subnets

#### Public Subnets (For Load Balancer & NAT Gateways)
1. Go to **Subnets → Create Subnet**.  
2. Choose **VPC:** `demo-app-vpc`.  
3. Create three public subnets:  
   - `demo-app-public-subnet-1` → `10.0.1.0/24` → **us-east-1a**  
   - `demo-app-public-subnet-2` → `10.0.2.0/24` → **us-east-1b**  
   - `demo-app-public-subnet-3` → `10.0.3.0/24` → **us-east-1c**  
4. Click **Create**.

#### Private Subnets (For App & DB Layers)
1. Go to **Subnets → Create Subnet**.  
2. Choose **VPC:** `demo-app-vpc`.  
3. Create three private subnets:  
   - `demo-app-private-subnet-1` → `10.0.11.0/24` → **us-east-1a**  
   - `demo-app-private-subnet-2` → `10.0.12.0/24` → **us-east-1b**  
   - `demo-app-private-subnet-3` → `10.0.13.0/24` → **us-east-1c**  
4. Click **Create**.

### 3. Create & Attach Internet Gateway (IGW)
1. Go to **Internet Gateways → Create Internet Gateway**.  
2. Enter:  
   - **Name:** `demo-app-igw`  
3. Click **Create**.  
4. Select `demo-app-igw` → Click **Actions → Attach to VPC**.  
5. Choose **VPC:** `demo-app-vpc` → Click **Attach**.

### 4. Create & Configure Route Tables

#### Public Route Table (For Public Subnets)
1. Go to **Route Tables → Create Route Table**.  
2. Enter:  
   - **Name:** `demo-app-public-rt`  
   - **VPC:** `demo-app-vpc`  
3. Click **Create**.  
4. Select `demo-app-public-rt` → **Routes → Edit Routes**.  
5. Add Route:  
   - **Destination:** `0.0.0.0/0`  
   - **Target:** Internet Gateway → `demo-app-igw`  
6. Click **Save Routes**.  
7. Go to **Subnet Associations → Edit Subnet Associations**.  
8. Select:  
   - ✅ `demo-app-public-subnet-1`  
   - ✅ `demo-app-public-subnet-2`  
   - ✅ `demo-app-public-subnet-3`  
9. Click **Save Associations**.

---

### 5. Create NAT Gateways

In this step, we will create NAT Gateways to allow instances in private subnets to access the internet for updates and downloads.

<details>
<summary>✅ Demo Setup (1 NAT Gateway)</summary>

This setup uses **a single NAT Gateway** for all private subnets to save costs.

#### Allocate Elastic IP

1. Go to **Elastic IPs** in AWS Console.
2. Click **Allocate Elastic IP → Allocate** (allocate **1 Elastic IP**).

#### Create NAT Gateway

1. Go to **NAT Gateways → Create NAT Gateway**.
2. Enter:

   * **Name:** `demo-app-nat-gateway-1`
   * **Subnet:** `demo-app-public-subnet-1`
   * **Elastic IP:** Select the Elastic IP you allocated
3. Click **Create NAT Gateway**.
4. Wait until the status shows **Available**.

✅ This NAT Gateway will be used for all private subnets.

</details>

<details>
<summary>✅ Prod Setup (3 NAT Gateways)</summary>

This setup uses **one NAT Gateway per public subnet** for high availability and fault tolerance.

#### Allocate Elastic IPs

1. Go to **Elastic IPs** in AWS Console.
2. Click **Allocate Elastic IP → Allocate** **3 times** (one for each NAT Gateway).

#### Create NAT Gateways

**NAT Gateway 1**

* Name: `demo-app-nat-gateway-1`
* Subnet: `demo-app-public-subnet-1`
* Elastic IP: first Elastic IP
* Click **Create**, wait until **Available**

**NAT Gateway 2**

* Name: `demo-app-nat-gateway-2`
* Subnet: `demo-app-public-subnet-2`
* Elastic IP: second Elastic IP
* Click **Create**, wait until **Available**

**NAT Gateway 3**

* Name: `demo-app-nat-gateway-3`
* Subnet: `demo-app-public-subnet-3`
* Elastic IP: third Elastic IP
* Click **Create**, wait until **Available**

✅ Each NAT Gateway will be associated with its respective private subnet.

</details>

✅ **Note:** Proceed to the next step (creating private route tables) only after all NAT Gateways show **Available**.

---

### 6. Create Route Tables for Private Subnets

In this step, we will create route tables to direct traffic from private subnets to the internet via NAT Gateways.

<details>
<summary>✅ Demo Setup (1 Route Table)</summary>

This setup uses **one NAT Gateway** for all private subnets → only **one route table** is needed.

#### Create Route Table

1. Go to **Route Tables → Create Route Table**.
2. Enter:

   * **Name:** `demo-app-private-rt-1`
   * **VPC:** `demo-app-vpc`
3. Click **Create**.

#### Edit Routes

1. Select `demo-app-private-rt-1` → **Edit Routes**.
2. Add Route:

   * **Destination:** `0.0.0.0/0`
   * **Target:** NAT → `demo-app-nat-gateway-1`
3. Click **Save Routes**.

#### Associate Subnets

1. Go to **Subnet Associations → Edit Subnet Associations**.
2. Select:

   * ✅ `demo-app-private-subnet-1`
   * ✅ `demo-app-private-subnet-2`
   * ✅ `demo-app-private-subnet-3`
3. Click **Save Associations**.

✅ All private subnets now use the same NAT Gateway via this route table.

</details>

<details>
<summary>✅ Prod Setup (3 Route Tables)</summary>

This setup uses **one NAT Gateway per private subnet**, requiring **three route tables** for high availability.

#### Route Table for Private Subnet 1

1. Go to **Route Tables → Create Route Table**.
2. Enter:

   * **Name:** `demo-app-private-rt-1`
   * **VPC:** `demo-app-vpc`
3. Click **Create**.
4. Edit Routes → Add Route:

   * Destination: `0.0.0.0/0`
   * Target: NAT → `demo-app-nat-gateway-1`
5. Associate **private-subnet-1**.

#### Route Table for Private Subnet 2

<details>
<summary>Expand for Steps</summary>

1. Go to **Route Tables → Create Route Table**.
2. Enter:

   * Name: `demo-app-private-rt-2`
   * VPC: `demo-app-vpc`
3. Click **Create**.
4. Edit Routes → Add Route:

   * Destination: `0.0.0.0/0`
   * Target: NAT → `demo-app-nat-gateway-2`
5. Associate **private-subnet-2**.

</details>

#### Route Table for Private Subnet 3

<details>
<summary>Expand for Steps</summary>

1. Go to **Route Tables → Create Route Table**.
2. Enter:

   * Name: `demo-app-private-rt-3`
   * VPC: `demo-app-vpc`
3. Click **Create**.
4. Edit Routes → Add Route:

   * Destination: `0.0.0.0/0`
   * Target: NAT → `demo-app-nat-gateway-3`
5. Associate **private-subnet-3**.

</details>

✅ Each private subnet now has its **own NAT Gateway via separate route tables**.

</details>

✅ **Note:**

* **Demo readers:** use only `demo-app-private-rt-1` for all private subnets.
* **Prod readers:** use three route tables, one per private subnet.
* After this step, your **VPC, subnets, Internet Gateway, NAT Gateways, and route tables** are fully configured — forming the foundation of your three-tier architecture.

---

## Part 2: Set Up RDS

<details>
<summary>📖 Theory: The Data Layer</summary>

In this step, we create a MySQL RDS instance to store the application’s data.

The database will hold user information, such as names and IDs.

The RDS instance is placed in private subnets for security, ensuring only the app layer can access it.

After this step, the database is ready to support the backend of your three-tier application.

Theory: The Data Layer
The database is a core component of any application, and in a multi-tier architecture, it's essential to keep it separate and secure. RDS (Relational Database Service) is a fully managed AWS service that handles the heavy lifting of running a database, like backups, patching, and scaling.  This means you don't have to worry about managing the underlying infrastructure, allowing you to focus on your application's data and logic.

We place the RDS instance in a private subnet to prevent direct access from the public internet. All traffic to and from the database must be routed through your application servers, which are in the application layer. This practice is a critical security measure that protects your data from unauthorized access.
When setting up RDS, you'll specify a database subnet group, which tells AWS to place your database instances within your designated private subnets, ensuring they are always isolated from public access.

</details>

### 1. Create an RDS Instance
1. Open **AWS Management Console → RDS**.  
2. Click **Create database**.  
3. Choose **Standard create**.  
4. Select **MySQL** as the database engine.  
5. Select **Free tier** to avoid charges.

### 2. Configure Database Settings
1. Set **DB instance identifier:** `my-demo-db`  
2. Set **Master username:** `admin`  
3. Set **Master password:** Choose a strong password and **note it down** somewhere safe.

### 3. Configure Storage
1. **Storage type:** General Purpose (SSD)  
2. **Allocated storage:** 20 GiB  
3. Keep **storage auto-scaling enabled** in Additional storage configuration.

### 4. Configure Connectivity
1. **VPC:** Select the VPC created earlier (`demo-app-vpc`).  
2. **Subnet group:** Select **Create new DB subnet group**.  
3. **Public access:** Select **No** (RDS should **not** be publicly accessible).  
4. **VPC security groups:**  
   - Click **Create new security group**  
   - Name: `demo-app-db-sg`

### 5. Create the RDS Instance
1. Click **Create database**.  
2. Wait for the RDS instance to reach **Available** status before proceeding.  

✅ **At this point, your MySQL RDS instance is ready and securely placed in your private subnets.**

---


## Part 3: Set Up S3

<details>
<summary>📖 Theory: The Storage Layer</summary>

In this step, we create an S3 bucket to store files uploaded by users.
	•	The bucket will hold images, documents, or any backend files required by the application.
	•	Proper permissions and versioning ensure security and easy recovery of files.
After this step, the S3 bucket is ready to support backend file storage.
This bucket will be used for backend purposes. Files uploaded to the demo-app will be stored here.

Theory: The Storage Layer
In a cloud-native architecture, it's best practice to separate file storage from your application's compute layer. Amazon S3 (Simple Storage Service) is an object storage service that provides a simple, scalable, and highly available solution for storing and retrieving any amount of data. Using S3 for your application's files means you don't have to worry about managing disk space on your servers.
S3 is incredibly durable, and features like Bucket Versioning give you a safety net by keeping multiple versions of a file, allowing you to easily recover from accidental deletions or overwrites. By enabling Block Public Access, we ensure that the bucket is not exposed to the public internet by default, which is a critical security measure to protect sensitive files.

</details>

### 1. Create an S3 Bucket
1. Open **AWS Console → Navigate to S3**.
2. Click **Create bucket**.
3. Enter a unique bucket name, for example:  
   `demo-app-backend-s3-bucket-1234`  
   🚨 **Important:** S3 bucket names must be globally unique across all AWS accounts.
4. Choose the **same region** as your VPC (e.g., `us-east-1`).
5. Click **Next**.

### 2. Configure Bucket Settings
1. Keep **Block Public Access enabled** (recommended for security).
2. Enable **Bucket Versioning** (optional) – useful to keep previous versions of uploaded files.
3. Leave other settings as default and click **Create bucket**.

✅ Your S3 bucket is now ready to store backend files for the demo application.

---

## Part 4: Configure SNS to Send Email Notifications on S3 File Uploads

<details>
<summary>📖 Theory: Decoupled Messaging and Events</summary>

In this step, we use SNS (Simple Notification Service) to get email alerts whenever a file is uploaded to S3.
	•	An SNS topic is created and linked to the S3 bucket.
	•	Users can subscribe via email to receive real-time notifications.
	•	This ensures the team is immediately aware of new uploads for processing or auditing.

Theory: Decoupled Messaging and Events
A key principle of a scalable architecture is to decouple services. Instead of one service directly calling another, we can use a messaging system to trigger events. Amazon SNS (Simple Notification Service) is a fully managed pub/sub messaging service. It allows you to send messages from one service (the "publisher") to multiple other services (the "subscribers").
Here, our S3 bucket is the publisher. When a new file is uploaded, S3 publishes an event notification to our SNS topic. The SNS topic then broadcasts this message to all of its subscribers. In this case, our subscribers are an email endpoint and, later, a Lambda function. This design pattern is powerful because it allows us to add or remove subscribers (like a new service or a different type of notification) without changing the S3 bucket's configuration.
By using SNS, we create a flexible, event-driven architecture that can easily scale to meet future needs, such as triggering an image-resizing service or a file-processing workflow.

</details>

### 1. Create an SNS Topic
1. Go to AWS Console → Amazon SNS.
2. Click **Topics → Create topic**.
3. Select **Type:** Standard.
4. Enter **Name:** `demo-app-sns-topic`.
5. Click **Create topic**.

### 2. Subscribe an Email to the SNS Topic
1. In SNS Console → Topics, select `demo-app-sns-topic`.
2. Click **Create subscription**.
3. Protocol: **Email**.
4. Endpoint: Enter your email address (e.g., `your-email@example.com`).
5. Click **Create subscription**.
6. Open your email and confirm the subscription (click the link from AWS SNS).

### 3. Update SNS Topic Policy to Allow S3 to Publish
1. In SNS Console, click `demo-app-sns-topic`.
2. Click **Edit → Access policy**.
3. Replace the existing policy with:

```json
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "AllowS3ToPublish",
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "SNS:Publish",
      "Resource": "arn:aws:sns:us-east-1:YOUR_AWS_ACCOUNT_ID:demo-app-sns-topic",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "YOUR_AWS_ACCOUNT_ID"
        }
      }
    }
  ]
}
```

> **Note:** Replace `YOUR_AWS_ACCOUNT_ID` with your AWS Account ID.

4. Click **Save changes**.

### 4. Configure S3 to Trigger SNS on File Upload

1. Open **AWS Console → S3** and select your bucket (e.g., `demo-app-backend-s3-bucket-1234`).
2. Go to **Properties → Event notifications**.
3. Click **Create event notification**.
4. Enter **Event name:** `demo-app-s3-object-upload-notification`.
5. Select **Event types:** `All object create events`.
6. Set **Destination:** **SNS topic**, select `demo-app-sns-topic`.
7. Click **Save changes**.

✅ Now, whenever a file is uploaded to this bucket, an email notification will be sent via SNS.

---

## Part 5: Create DynamoDB Table and Lambda for File Metadata Extraction & Storage

<details>
<summary>📖 Theory: Serverless Data Processing and Storage</summary>

In this step, we store metadata of uploaded files in DynamoDB using a Lambda function:
	•	A DynamoDB table is created to save details like file name, bucket name, and upload timestamp.
	•	Lambda is triggered by the SNS notification from S3 uploads.
	•	This automates tracking and management of uploaded files, enabling easy retrieval and further processing.

Theory: Serverless Data Processing and Storage
This step introduces two powerful concepts: serverless computing and NoSQL databases.
AWS Lambda is a serverless, event-driven compute service. This means you don't have to provision or manage servers. You simply upload your code, and Lambda runs it in response to specific events. In our case, the event is a message published to an SNS topic. Lambda acts as the "glue" between our storage and data layers, automating a crucial task without any server maintenance.
Amazon DynamoDB is a fully managed NoSQL database. Unlike traditional relational databases (like MySQL), DynamoDB is designed for key-value and document data. It's incredibly fast and scalable, and it doesn't require a fixed schema. This makes it perfect for our use case, where we're only storing simple, structured data about each uploaded file, such as the file_name, bucket_name, and a timestamp.
The combined workflow is a prime example of a modern, event-driven architecture: a file upload to S3 triggers an SNS message, which in turn invokes the Lambda function. The Lambda function then automatically extracts the file's metadata from the event and stores it in the DynamoDB table. This entire process is automated, scalable, and requires no server management.

</details>

### 1. Create a DynamoDB Table
1. Go to AWS Console → DynamoDB → Tables → **Create Table**.
2. Enter **Table name:** `demo-app-file-metadata-dynamodb`.
3. Set **Partition Key:**  
   - Name: `file_name`  
   - Type: String
4. Leave all other settings as default.
5. Click **Create Table**.

> **Important:** You don’t need to manually define other attributes like `upload_time` or `file_size`. These will be dynamically inserted by the Lambda function. You can view them under **Explore Items** in DynamoDB.

### 2. Create an IAM Role for Lambda
1. Go to **IAM Console → Roles → Create role**.
2. Select **AWS Service → Lambda → Next**.
3. Attach the following policies:
   - `AmazonS3ReadOnlyAccess` (To read files from S3)  
   - `AmazonDynamoDBFullAccess` (To write metadata to DynamoDB)  
   - `AWSLambdaBasicExecutionRole` (For CloudWatch logging)
4. Create the role and note the **Role ARN**.
5. Name the role: `demo-app-lambda-iam-role`.

### 3. Create a Lambda Function
1. Go to **Lambda Console → Create function**.
2. Choose **Author from scratch**.
3. Enter **Function Name:** `demo-app-metadata-lambda`.
4. Select **Python 3.x** as Runtime.
5. Choose **Use an existing role** and select the IAM role created earlier (`demo-app-lambda-iam-role`).
6. Click **Create Function**.

### 4. Subscribe Lambda to Existing SNS Topic
1. Go to **SNS Console → Your SNS Topic (`demo-app-sns-topic`)**.
2. Click **Create Subscription**.
3. Protocol: **AWS Lambda**.
4. Select the Lambda Function you created (`demo-app-metadata-lambda`).
5. Click **Create Subscription**.
6. Ensure Lambda permissions allow SNS to invoke the function (IAM might require adding SNS invoke permissions).

### 5. Update Lambda Code to Process SNS Events
1. Go to **Lambda → `demo-app-metadata-lambda` → Code**.
2. Paste the following Python code:

```python
import boto3
import json

# Set the AWS Region
AWS_REGION = "us-east-1"

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)
TABLE_NAME = "demo-app-file-metadata-dynamodb"

def lambda_handler(event, context):
    try:
        print("✅ Event received:", json.dumps(event, indent=2))
        for record in event.get("Records", []):
            sns_message = record["Sns"]["Message"]
            print("✅ Extracted SNS Message:", sns_message)
            s3_event = json.loads(sns_message)

            for s3_record in s3_event.get("Records", []):
                s3_info = s3_record.get("s3", {})
                bucket_name = s3_info.get("bucket", {}).get("name")
                file_name = s3_info.get("object", {}).get("key")

                if not bucket_name or not file_name:
                    print("❌ Missing bucket name or file name, skipping record.")
                    continue 

                print(f"✅ Extracted File: {file_name} from Bucket: {bucket_name}")

                table = dynamodb.Table(TABLE_NAME)
                table.put_item(
                    Item={
                        "file_name": file_name,
                        "bucket_name": bucket_name,
                        "timestamp": s3_record["eventTime"]
                    }
                )

        return {"statusCode": 200, "body": "File metadata stored successfully"}

    except Exception as e:
        print("❌ Error:", str(e))
        return {"statusCode": 500, "body": f"Error: {str(e)}"}
```

3. Click **Deploy**.

### 6. Quick Test

After setting up S3, SNS, DynamoDB, and Lambda:

1. Upload a file to your S3 bucket (e.g., `demo-app-backend-s3-bucket-1234`).
2. You should receive an email notification from SNS.
3. Go to **Lambda → demo-app-metadata-lambda → Monitor → View CloudWatch Logs**.
4. Open the latest log stream.
5. You should see a log entry like:

```
Extracted File: <your file name> from Bucket: <your bucket name>
```

✅ This confirms that uploading a file to S3 triggers SNS, which sends an email, invokes Lambda, and writes metadata to DynamoDB successfully.

---

## Part 6: Deploy a Flask Application on Test AMI Builder EC2 with RDS & S3, DynamoDB Integration in Public Subnet

<details>
<summary>📖 Theory: The Application Layer and Service Integration</summary>

In this step, we deploy the backend Flask application on a test EC2 instance with full integration to RDS, S3, and DynamoDB:
Theory: The Application Layer and Service Integration
The core of our three-tier architecture is the application layer, where the business logic lives. In this setup, an EC2 (Elastic Compute Cloud) instance serves as our application server. Think of EC2 as a virtual machine in the cloud that gives you complete control over your operating system and environment. We're using a public subnet for this instance to make it easily accessible for testing.
To ensure our application can securely interact with our other services (RDS, S3, and DynamoDB), we use an IAM (Identity and Access Management) Role. An IAM role is a set of permissions that we can grant to an AWS service, in this case, our EC2 instance. By attaching a role to the instance, we give our Flask application the necessary permissions to read and write to S3 and DynamoDB without ever embedding sensitive access keys in our code. This is a crucial security practice.
The Flask application itself acts as the communication hub, connecting the frontend to the backend services.
	•	It uses pymysql to connect to the RDS database (the data layer) and perform CRUD operations on user data.
	•	It uses boto3 (the AWS SDK for Python) to interact with S3 for file uploads and to retrieve metadata from the DynamoDB table.
Finally, we use systemd to manage the Flask application. This ensures that the application automatically starts when the EC2 instance reboots and that it keeps running, making our deployment more robust and reliable.

</details>


### 1. Create an IAM Role for S3 and DynamoDB Access
1. Open AWS IAM Console → **Roles → Create Role**.
2. Select **AWS Service → EC2 → Next**.
3. Attach policies:  
   - `AmazonS3FullAccess`  
   - `AmazonDynamoDBReadOnlyAccess`
4. Name the role: `demo-app-s3-dynamo-iam-role` → Click **Create**.

### 2. Launch a Test and AMI Builder EC2 Instance
1. Open AWS EC2 Console → **Launch Instance**.
2. Enter **Instance Name:** `demo-app-test-ami-builder`.
3. Choose AMI: Ubuntu 24.04 LTS (or latest).
4. Instance Type: `t2.micro` (free-tier) or as required.
5. Key Pair: Create or select an existing key pair (download `.pem` for terminal, `.ppk` for Putty).  
   Name: `demo-app-private-key`.
6. Network: Select your VPC → Subnet: `demo-app-public-subnet-1`.
7. Enable **Auto-assign Public IP**.
8. Security Group: Create or select:  
   - Name: `demo-app-test-ami-builder-sg`  
   - Allow SSH (22) from your IP  
   - Allow 5000 from your IP (Flask app)
9. Attach IAM role: `demo-app-s3-dynamo-iam-role`.
10. Launch the instance and copy the **Public IP**.

### 3. Connect to the Test AMI Builder

**Terminal:**  
```bash
chmod 400 /path/to/your/key/demo-app-private-key.pem
ssh -i /path/to/your/key/demo-app-private-key.pem ubuntu@<EC2_PUBLIC_IP>
```

**Putty:** use the `.ppk` file.

Your instance is ready for package installation, app deployment, testing, and AMI creation.

### 4. Install Dependencies

```bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install software
sudo apt install python3 python3-pip python3-venv git vim -y

# Set up Python virtual environment
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install flask pymysql boto3
pip install flask-cors
```

### 5. Deploy Flask Application: Backend - Application Layer

1. Create application directory:

```bash
mkdir /home/ubuntu/flask-app
cd /home/ubuntu/flask-app
vim app.py
```

2. Paste the Flask app code below. Update `RDS_HOST`, `RDS_USER`, `RDS_PASSWORD`, `S3_BUCKET` accordingly:

```python
from flask import Flask, request, jsonify
import pymysql
import boto3
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# RDS and S3 Configurations
RDS_HOST = "CHANGE_ME"
RDS_USER = "CHANGE_ME"
RDS_PASSWORD = "CHANGE_ME"
RDS_DATABASE = "demo"
S3_BUCKET = "CHANGE_ME"
DYNAMODB_TABLE_NAME = "demo-app-file-metadata-dynamodb"

# AWS S3 Client
s3_client = boto3.client("s3")

# Database initialization
def initialize_database():
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD)
    with conn.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {RDS_DATABASE}")
    conn.commit()
    conn.close()
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)
    with conn.cursor() as cursor:
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL
            )
        """)
    conn.commit()
    conn.close()

def get_db_connection():
    return pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)

# API Routes
@app.route("/insert", methods=["POST"])
def insert():
    data = request.json
    name = data["name"]
    conn = get_db_connection()
    with conn.cursor() as cursor:
        cursor.execute("INSERT INTO users (name) VALUES (%s)", (name,))
    conn.commit()
    conn.close()
    return jsonify({"message": "User inserted successfully!"})

@app.route("/fetch", methods=["GET"])
def fetch():
    conn = get_db_connection()
    with conn.cursor() as cursor:
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
    conn.close()
    return jsonify({"users": users})

@app.route("/upload", methods=["POST"])
def upload():
    file = request.files["file"]
    s3_client.upload_fileobj(file, S3_BUCKET, file.filename)
    return jsonify({"message": "File uploaded successfully!"})

@app.route("/list_files", methods=["GET"])
def list_files():
    objects = s3_client.list_objects_v2(Bucket=S3_BUCKET)
    files = [obj["Key"] for obj in objects.get("Contents", [])]
    return jsonify({"files": files})

@app.route("/get_file_metadata", methods=["GET"])
def get_file_metadata():
    dynamodb = boto3.resource("dynamodb", region_name="us-east-1")
    table = dynamodb.Table(DYNAMODB_TABLE_NAME)
    response = table.scan()
    metadata = response.get("Items", [])
    return jsonify({"files_metadata": metadata})

if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000, debug=True)
```

### 6. Deploy HTML + JavaScript Frontend on S3

1. Create S3 Bucket for frontend (e.g., `demo-app-frontend-s3-bucket-6789`).
2. Disable **Block public access**.
3. Enable **Static website hosting** → Index document: `index.html`.
4. Set **Bucket Policy**:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::demo-app-frontend-s3-bucket-6789/*"
        }
    ]
}
```

5. Upload `index.html` and update `API_BASE` with EC2 IP:Port.

### 7. Start the Flask Application

```bash
python3 app.py
```

> If connection fails due to RDS security group, allow inbound 3306 from `demo-app-test-ami-builder-sg`.

### 8. Configure Flask as a Systemd Service

1. Create service file:

```bash
sudo vim /etc/systemd/system/flask-app.service
```

```ini
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/flask-app
ExecStart=/home/ubuntu/venv/bin/python3 /home/ubuntu/flask-app/app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

2. Reload systemd and enable service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app
sudo systemctl status flask-app
```

3. Verify via browser using S3 Static Website URL.
4. Test auto-start after reboot:

```bash
sudo reboot
sudo systemctl status flask-app
```

✅ Your Flask app is now running as a **persistent, auto-starting systemd service**, integrated with **RDS, S3, and DynamoDB**, and connected to the frontend hosted on S3.

---

## Part 7: Create an AMI, Launch Template, and Auto Scaling Group

<details>
<summary>📖 Theory: Immutable Infrastructure and Automated Scaling</summary>
In this step, we prepare the infrastructure for scalable deployment of the Flask application:
Since Launch Configurations are being replaced by Launch Templates, we will use a Launch Template instead. This approach is more flexible, supports multiple versions, and is recommended by AWS.
Theory: Immutable Infrastructure and Automated Scaling
The final piece of our modern cloud architecture is building for scalability and resilience. We do this by adopting an immutable infrastructure pattern. Instead of making changes to a running server, we create a new, pre-configured image and launch new servers from it. This ensures consistency and prevents configuration drift.
An AMI (Amazon Machine Image) is the foundation of this pattern. It's a static, complete copy of our EC2 instance, including the operating system, our Flask application, and all its dependencies. We can use this single AMI to create a consistent fleet of new servers.
The Launch Template acts as the blueprint for our new instances. It combines all the necessary configuration details—like which AMI to use, the instance type, security groups, and even a script to start our Flask app—into a single, versioned resource. This makes it easy to manage and update our infrastructure.
The Auto Scaling Group (ASG) is the key to automating our scaling. It monitors the health and performance of our instances. Using the Launch Template, the ASG can automatically add more EC2 instances when the application load increases or replace any unhealthy instances, guaranteeing high availability and responsiveness. This setup provides the scalability and resilience needed for a production application.

</details>

### 1. Create an AMI from the Running EC2 Instance

#### 1.1 Stop the Flask Application
Before creating an AMI, stop the Flask app service running on the `demo-app-test-ami-builder` instance:
```bash
sudo systemctl stop flask-app
```

#### 1.2 Create an AMI from the Running Instance

1. Go to AWS Console → **EC2 Dashboard**
2. Select the running instance
3. Click **Actions → Image and templates → Create Image**
4. Provide an **Image Name** (e.g., `demo-app-ami`)
5. Enable **No Reboot** (optional but recommended)
6. Click **Create Image**

#### 1.3 Verify AMI Creation

1. Navigate to EC2 Dashboard → **AMIs**
2. Wait until the AMI status changes to `available`

---

### 2. Create a Launch Template

A Launch Template defines how instances are launched with predefined configurations.

#### 2.1 Open Launch Template Wizard

1. Go to EC2 Dashboard → **Launch Templates**
2. Click **Create Launch Template**

#### 2.2 Configure Launch Template

* **Template Name:** `demo-app-launch-template`
* **AMI ID:** Select the AMI created above (`demo-app-ami`)
* **Instance Type:** `t2.micro` (or as per requirement)
* **Key pair name:** `demo-app-private-key`
* **Subnet:** Do not select (ASG will select subnets)
* **Security Group:** Do not specify now (configure later)

  * Name: `demo-app-lt-asg-sg`
  * Description: Access from Bastion Host and LB
* **VPC:** `demo-app-vpc`
* **Storage:** Keep default (or modify as needed)

**Advanced details:**

* **IAM instance profile:** Select `demo-app-s3-dynamo-iam-role`
* **User Data:** Add the following script to start the Flask service on instance launch:

```bash
#!/bin/bash
sudo systemctl start flask-app
sudo systemctl enable flask-app
```

* Review and click **Create Launch Template**

### 3. Create an Auto Scaling Group (ASG)

The ASG will automatically manage EC2 instances to ensure availability.

#### 3.1 Open ASG Wizard

1. Go to EC2 Dashboard → **Auto Scaling Groups**
2. Click **Create Auto Scaling Group**

#### 3.2 Configure ASG

* **ASG Name:** `demo-app-asg`
* **Launch Template:** Select `demo-app-launch-template`
* **VPC and Subnets:**

  * VPC: `demo-app-vpc`
  * Subnets (Private): `demo-app-private-subnet-1`, `demo-app-private-subnet-2`, `demo-app-private-subnet-3`

#### 3.3 Set Scaling Policies

* **Desired Capacity:** 2
* **Min Instances:** 2
* **Max Instances:** 3
* **Automatic scaling:** Target tracking scaling policy

#### 3.4 Add Tags

* **Key:** Name

* **Value:** app-demo-asg-instances

* Review & Click **Create ASG**

### 4. Verify ASG Setup

#### 4.1 Check if ASG Launches Instances

* Go to **EC2 Dashboard → Instances**
* Confirm that new instances are being launched by the ASG

#### 4.2 Verify New Instances

* Check the **Launch Time** of the instances to confirm they are newly created
* Verify that the **IAM Role** (`demo-app-s3-dynamo-iam-role`) is attached to the instances


## Part 8: Attach Load Balancer to Auto Scaling Group (ASG)

<details>
<summary>📖 Theory: High Availability and Traffic Management</summary>

In this step, we make the Flask application highly available and fault-tolerant:
Theory: High Availability and Traffic Management
To ensure our application can handle a large number of users and remain available even if an instance fails, we use a Load Balancer. A Load Balancer (ALB) acts as a single point of contact for all incoming traffic. It then automatically distributes that traffic across multiple healthy instances in our Auto Scaling Group (ASG). This prevents any single instance from becoming a bottleneck and ensures that the application remains responsive, even under heavy load.
A Target Group (TG) is a logical grouping of our EC2 instances. The Load Balancer forwards traffic to a Target Group, and the Target Group then routes the requests to the individual instances. The Target Group also performs health checks to ensure that only healthy instances receive traffic. If an instance fails a health check, the Target Group automatically stops sending traffic to it until it recovers or is replaced by the ASG. This continuous health monitoring is what makes our architecture fault-tolerant and highly available.
The combination of a Load Balancer, a Target Group, and an Auto Scaling Group creates a robust, self-healing system: the ASG maintains the desired number of instances, the Target Group monitors their health, and the Load Balancer ensures that all user requests are efficiently distributed among the available, healthy instances.

</details>

### 1. Create a Target Group (TG)
1. Go to AWS Console → **EC2 Dashboard**  
2. On the left panel, click **Target Groups** under **Load Balancing**  
3. Click **Create target group**  

Fill in the details:  
- **Target type:** Instance  
- **Target group name:** `demo-app-tg`  
- **Protocol:** HTTP  
- **Port:** 5000 (Flask app port)  
- **VPC:** `demo-app-vpc`  
- **Health check protocol:** HTTP  
- **Health check path:** `/`  

- Click **Next**  
- **Do not manually register targets** (Auto Scaling will handle this)  
- Click **Create target group**

### 2. Create an Application Load Balancer (ALB)

#### 2.1 First Create a Security Group
1. Go to EC2 → **Security Groups** → **Create Security Group**  
2. Fill details:  
   - **Security group name:** `demo-app-lb-sg`  
   - **Description:** `demo-app-lb-sg for public access`  
   - **VPC:** `demo-app-vpc`  
   - **Inbound Rule:** Port 80, Source: Anywhere  

#### 2.2 Create the ALB
1. Go to EC2 Dashboard → **Load Balancers** → **Create Load Balancer**  
2. Select **Application Load Balancer (ALB)**  

**Configure basic details:**  
- **Name:** `demo-app-alb`  
- **Scheme:** Internet-facing  
- **IP address type:** IPv4  
- **VPC:** `demo-app-vpc`  
- **Availability Zones:** Select public subnets:  
  `demo-app-public-subnet-1`, `demo-app-public-subnet-2`, `demo-app-public-subnet-3`

**Configure Security Groups:**  
- Use the SG created above: `demo-app-lb-sg`  

**Configure Listeners and Routing:**  
- **Listener protocol:** HTTP  
- **Listener port:** 80  
- **Forward to target group:** Select `demo-app-tg`  

- Click **Create Load Balancer**

### 3. Attach the Target Group to the Auto Scaling Group (ASG)
1. Go to EC2 → **Auto Scaling Groups**  
2. Select your ASG  
3. Click **Edit**  
4. Scroll to **Load balancing → Load Balancers**  
5. Tick **Application, Network or Gateway Load Balancer target groups**  
6. Select the target group `demo-app-tg`  
7. Click **Update**

### 4. Verify Load Balancer and ASG Integration
1. Go to EC2 Dashboard → **Target Groups** → Select `demo-app-tg`  
2. Click on **Targets** → Ensure ASG instances appear here  
3. If instances are not healthy:  
   - Go to ASG SG `demo-app-lt-asg-sg`  
   - **Edit Inbound Rules**  
   - Add rule:  
     - **Port Range:** 5000  
     - **Source:** Custom → select `demo-app-lb-sg`  
   - Save rules  

4. Test Load Balancer URL  
- Go to **Load Balancers → demo-app-lb**  
- Copy **DNS Name**  
- Open a browser → Enter `http://<ALB-DNS-Name>`  
- Your Flask app should load!

### 5. Update `index.html`
Since the frontend is hosted on S3 and the backend is now behind the ALB:  
1. Update `API_BASE` in `index.html` to point to `http://<ALB-DNS-Name>:80`  
2. Re-upload `index.html` to the frontend S3 bucket (e.g., `demo-app-frontend-s3-bucket-6789`)  
3. Access the S3 website URL and verify the frontend connects to the backend via the ALB

---

## Part 9: Create a Bastion Host in Public Subnet to Access Instances in Private Subnet

<details>
<summary>📖 Theory: Secure Access to Private Resources</summary>
In this step, we will launch a public EC2 instance that acts as a Bastion Host. It will allow us to securely connect to and manage our private instances without exposing them directly to the internet.
Theory: Secure Access to Private Resources
In a secure cloud architecture, resources like our application servers and databases are placed in a private subnet to shield them from direct public access. While this is great for security, it presents a challenge for administrators who need to connect to these instances for maintenance or debugging. This is where a Bastion Host comes in.
A Bastion Host is a dedicated, hardened EC2 instance located in a public subnet. It acts as a jump server or a single point of entry into our private network. Instead of opening up SSH (port 22) access from the internet to every single private instance, we only open it to the Bastion Host. This significantly reduces the attack surface and provides a centralized, monitored access point.
The process is simple and secure: an administrator first connects to the Bastion Host via SSH, and from there, establishes a second, internal SSH connection to the desired private instance. This creates a secure "tunnel" that allows for management without compromising the security of our private resources.


</details>

### 1. Launch an EC2 Instance (Bastion Host)
1. Go to AWS Management Console → **EC2** → **Launch Instance**  
2. Enter an instance name: `demo-app-bastion-host`  

**Choose AMI:**  
- Ubuntu 24.04 LTS (or latest available)

**Choose Instance Type:**  
- t2.micro (free-tier) or as required  

**Create/Select Key Pair:**  
- If no key exists, create a new one, download, and keep it safe  
- **Name:** demo-app-private-key  
- Download `.ppk` for Putty  
- Download `.pem` for Terminal  

### 2. Configure Networking
- **Network:** Select the VPC where the Bastion Host should be deployed  
- **Subnet:** Select a Public Subnet (`demo-app-public-subnet-1`)  
- **Auto-Assign Public IP:** Enabled  

### 3. Set Up Security Group
- Create a new SG or use an existing one:  
  - **Name:** `demo-app-bastion-host-sg`  
  - **Inbound Rule:** Allow SSH (port 22) from your IP (or 0.0.0.0/0 for testing; restrict in production)  

### 4. Launch the Instance
- Click **Launch Instance** and wait for it to start  
- Copy the **Public IP Address** of the Bastion Host  

### ⚠️ Note
After creating the Auto Scaling Group (ASG) with a new Launch Template and SG, the ASG instances may fail to connect to the RDS because the new SG is not allowed in the RDS SG.  

**To fix this:**  
1. Update the **RDS Security Group** to allow inbound access from the new ASG SG.  
2. Delete the existing ASG instances.  
3. Let the ASG launch new instances — they will now connect to RDS successfully and the application will work correctly.

---

## Part 10: Connect From Bastion Host to Private Instance

<details>
<summary>📖 Theory: Secure Access and Debugging with Bastion Hosts</summary>
In this step, we will use the Bastion Host to securely access our private EC2 instances. This ensures all management is done through the Bastion, keeping private instances safe from direct internet access.
Theory: Secure Access and Debugging with Bastion Hosts
Now that we have our Bastion Host, we'll use it to securely manage and debug our private instances. The core principle here is that all administrative access flows through a single, controlled entry point. This is a critical security practice for any production environment.
The first step is to get the necessary credentials onto the Bastion Host. We use the Secure Copy Protocol (SCP) to copy our private key from our local machine to the Bastion Host. This private key is the credential that allows the Bastion Host to authenticate with the other private instances.
Once we are on the Bastion Host, we use a standard SSH command to "jump" to the private instance. This second SSH connection is made from the public Bastion Host to the private IP address of the target instance. The connection is secured because we've updated the ASG security group to only allow inbound traffic on port 22 (SSH) from the Bastion Host's security group. This creates a highly secure, restricted path for all management tasks.
This setup is invaluable for debugging. By connecting to the private instance via the Bastion Host, you can run diagnostic commands like journalctl to view application logs and systemctl to manage the Flask service. This allows you to troubleshoot issues directly on the server without ever exposing it to the public internet.

</details>

### 1. Copy the Private Key to Bastion Host
**From Terminal (Linux/Mac):**  
```bash
scp -vvv -i ~/Downloads/demo-app-private-key.pem ~/Downloads/demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>:/home/ubuntu/
```

**From Windows:**

* Use a tool like **WinSCP** and upload the private key to `/home/ubuntu/` directory on the Bastion Host.

### 2. Update ASG Security Group

* Update the ASG security group `demo-app-lt-asg-sg`
* Add an **Inbound Rule:**

  * **Port:** 22
  * **Source:** Custom → select `demo-app-bastion-host-sg`

### 3. Connect to the Bastion Host

**Terminal (Linux/Mac):**

```bash
chmod 400 demo-app-private-key.pem
ssh -i demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>
```

**Putty (Windows):**

* Use the `.ppk` file
* Replace `<BASTION_PUBLIC_IP>` with the public IP of your Bastion Host

Your Bastion Host is now ready to access private instances securely! 🚀

### 4. Access Private Instance from Bastion Host

1. Verify the private key is on Bastion Host:

```bash
ls -l
```

2. Get the private IP of a private instance from the AWS Console → EC2 → Instances

3. Connect to the private instance:

```bash
ssh -i "demo-app-private-key.pem" ubuntu@<PRIVATE_EC2_IP>
```

### 5. Debug and Manage Flask App on Private Instance

1. Install `netstat` command for debugging:

```bash
sudo apt install net-tools
```

2. Check Flask service logs:

```bash
sudo journalctl -u flask-app.service -n 50 --no-pager
```

3. Stop, start, and check Flask service:

```bash
sudo systemctl stop flask-app
sudo systemctl start flask-app
sudo systemctl status flask-app
```

4. Check logs again to verify:

```bash
sudo journalctl -u flask-app.service -n 50 --no-pager
```

---

## Part 11: Cleanup – Terminate All Resources

<details>
<summary>📖 Theory: The Importance of a Clean AWS Environment</summary>

After testing your three-tier application, you should clean up all AWS resources to avoid incurring charges. In this step, we will terminate EC2 instances, delete RDS databases, remove S3 buckets, and delete other associated resources.
Theory: The Importance of a Clean AWS Environment
A key principle of cloud computing is paying for what you use. The final, and arguably most important, step of any project is to clean up your environment. This is crucial for cost management, ensuring you don't continue to pay for resources that are no longer needed. Beyond cost, a clean environment is also easier to manage and less prone to configuration errors.
The cleanup process should be done in a specific, dependency-based order. You can't delete a VPC if there are still resources running inside it. Therefore, you must first terminate the dependent services.
	1	EC2 Instances and Auto Scaling Groups are the first to go. Since the ASG manages the instances, deleting the ASG will automatically terminate the instances it launched.
	2	Next, AMIs and their underlying snapshots should be deregistered and deleted.
	3	Then, delete the databases (RDS, DynamoDB), storage buckets (S3), and messaging topics (SNS).
	4	Finally, you can clean up the networking components: the custom Security Groups, Route Tables, and Internet Gateway. The VPC is the last resource to be deleted, as it is the container for everything else.
By following this careful process, you ensure that all resources are properly removed, leaving your AWS account in a clean state.

</details>

### Steps:

1. **Terminate EC2 Instances**

   * Go to **EC2 → Instances**.
   * Select all instances (including Bastion host and application instances) and click **Terminate Instance**.

2. **Delete Auto Scaling Group & Launch Template**

   * Go to **EC2 → Auto Scaling Groups**.
   * Delete the Auto Scaling Group.
   * Go to **Launch Templates** and delete the corresponding launch template.

3. **Deregister AMI**

   * Go to **EC2 → AMIs**.
   * Select your AMI and click **Deregister**.
   * Delete associated snapshots to free up storage.

4. **Delete RDS Database**

   * Go to **RDS → Databases**.
   * Select your database and choose **Delete**.
   * Optionally, skip final snapshot if not needed.

5. **Delete S3 Buckets**

   * Go to **S3 → Buckets**.
   * Empty all buckets and delete them.

6. **Delete DynamoDB Table**

   * Go to **DynamoDB → Tables**.
   * Select the table used for file metadata and delete it.

7. **Delete SNS Topics**

   * Go to **SNS → Topics**.
   * Delete any topics created for notifications.

8. **Delete Security Groups and VPC**

   * Go to **VPC → Security Groups** and delete custom security groups.
   * Delete subnets, Internet Gateway, and finally the VPC itself.

> ⚠️ Make sure to double-check before deleting resources to avoid accidentally removing something important.

# Three-Tier Application Setup on AWS

## Network Setup

### 1. Create a VPC
Go to AWS Console → VPC Dashboard.
1. Click **Create VPC**
2. Enter:
   - **Name:** `demo-app-vpc`
   - **IPv4 CIDR Block:** `10.0.0.0/16`
3. Click **Create VPC**.

### 2. Create Public & Private Subnets
#### Public Subnets (For Load Balancer & NAT Gateways)
Go to **Subnets** → Click **Create Subnet**.
1. Choose **VPC:** `demo-app-vpc`.
2. Create three public subnets:
   - `demo-app-public-subnet-1` (`10.0.1.0/24`) → `us-east-1a`
   - `demo-app-public-subnet-2` (`10.0.2.0/24`) → `us-east-1b`
   - `demo-app-public-subnet-3` (`10.0.3.0/24`) → `us-east-1c`
3. Click **Create**.

#### Private Subnets (For App & DB Layers)
1. Create three private subnets:
   - `demo-app-private-subnet-1` (`10.0.11.0/24`) → `us-east-1a`
   - `demo-app-private-subnet-2` (`10.0.12.0/24`) → `us-east-1b`
   - `demo-app-private-subnet-3` (`10.0.13.0/24`) → `us-east-1c`
2. Click **Create**.

### 3. Create & Attach Internet Gateway (IGW)
Go to **Internet Gateways** → Click **Create Internet Gateway**.
1. Enter:
   - **Name:** `demo-app-igw`
2. Click **Create**.
3. Select `demo-app-igw` → Click **Actions** → **Attach to VPC** → Select `demo-app-vpc` → Click **Attach**.

### 4. Create & Configure Route Tables
#### Public Route Table (For Public Subnets)
Go to **Route Tables** → Click **Create Route Table**.
1. Enter:
   - **Name:** `demo-app-public-rt`
   - **VPC:** `demo-app-vpc`
2. Click **Create**.
3. Select `demo-app-public-rt` → **Routes** → Click **Edit Routes**.
   - **Add Route:**
     - **Destination:** `0.0.0.0/0`
     - **Target:** `Internet Gateway` → `demo-app-igw`
   - Click **Save Routes**.
4. Go to **Subnet Associations** → Click **Edit Subnet Associations**.
   - Select:
     - ✅ `demo-app-public-subnet-1`
     - ✅ `demo-app-public-subnet-2`
     - ✅ `demo-app-public-subnet-3`
   - Click **Save Associations**.

### 5. Create NAT Gateways (One per Private Subnet)
#### Allocate 3 Elastic IPs
Go to **Elastic IPs** → Click **Allocate Elastic IP** → Click **Allocate**.
- Repeat 2 more times (Total: **3 Elastic IPs**).

#### Create 3 NAT Gateways (One in Each Public Subnet)
Go to **NAT Gateways** → Click **Create NAT Gateway**.
1. `demo-app-nat-gateway-1`:
   - **Name:** `demo-app-nat-gateway-1`
   - **Subnet:** `demo-app-public-subnet-1`
   - **Elastic IP:** (Select first one)
2. `demo-app-nat-gateway-2`:
   - **Name:** `demo-app-nat-gateway-2`
   - **Subnet:** `demo-app-public-subnet-2`
   - **Elastic IP:** (Select second one)
3. `demo-app-nat-gateway-3`:
   - **Name:** `demo-app-nat-gateway-3`
   - **Subnet:** `demo-app-public-subnet-3`
   - **Elastic IP:** (Select third one)
4. Click **Create**.

### 6. Create Separate Route Tables for Each Private Subnet
#### Route Table for Private-Subnet-1
Go to **Route Tables** → Click **Create Route Table**.
1. Enter:
   - **Name:** `demo-app-private-rt-1`
   - **VPC:** `demo-app-vpc`
2. Click **Create**.
3. Select `demo-app-private-rt-1` → **Edit Routes**.
   - **Add Route:**
     - **Destination:** `0.0.0.0/0`
     - **Target:** `NAT Gateway` → `demo-app-nat-gateway-1`
   - Click **Save Routes**.
4. Go to **Subnet Associations** → Click **Edit Subnet Associations**.
   - Select:
     - ✅ `demo-app-private-subnet-1`
   - Click **Save Associations**.

#### Route Table for Private-Subnet-2
1. Go to **Route Tables** → Click **Create Route Table**.
2. Enter:
   - **Name:** `demo-app-private-rt-2`
   - **VPC:** `demo-app-vpc`
3. Click **Create**.
4. Select `demo-app-private-rt-2` → **Edit Routes**.
   - **Add Route:**
     - **Destination:** `0.0.0.0/0`
     - **Target:** `NAT Gateway` → `demo-app-nat-gateway-2`
   - Click **Save Routes**.
5. Go to **Subnet Associations** → Click **Edit Subnet Associations**.
   - Select:
     - ✅ `demo-app-private-subnet-2`
   - Click **Save Associations**.

#### Route Table for Private-Subnet-3
1. Go to **Route Tables** → Click **Create Route Table**.
2. Enter:
   - **Name:** `demo-app-private-rt-3`
   - **VPC:** `demo-app-vpc`
3. Click **Create**.
4. Select `demo-app-private-rt-3` → **Edit Routes**.
   - **Add Route:**
     - **Destination:** `0.0.0.0/0`
     - **Target:** `NAT Gateway` → `demo-app-nat-gateway-3`
   - Click **Save Routes**.
5. Go to **Subnet Associations** → Click **Edit Subnet Associations**.
   - Select:
     - ✅ `demo-app-private-subnet-3`
   - Click **Save Associations**.



## Part 2: Set Up RDS

### 1. Create an RDS Instance
Open the AWS Management Console → Navigate to RDS.
Click on Create database.
Choose Standard create.
Select MySQL as the database engine.
Select Free tier to avoid charges.

### 2. Configure Database Settings
Set DB instance identifier: my-demo-db.
Set Master username: admin.
Set Master password: Choose a strong password and note it down.

### 3. Configure Storage
Storage type: Select General Purpose (SSD).
Allocated storage: Set to 20 GiB.
Keep storage auto-scaling enabled in Additional storage configuration.

### 4. Configure Connectivity
VPC: Select the VPC created earlier.
Subnet group:
Select Create new DB subnet group.
Public access: Select No (RDS should not be publicly accessible).
VPC security groups:
Click Create new security group.
Name: demo-app-db-sg

### 5. Create the RDS Instance
Click Create database.
Wait for the instance to be available before proceeding further.


## Part 3: Set Up S3

This bucket will be used for backend purposes. Files uploaded to the demo-app will be stored here.

### 1. Create an S3 Bucket
1. Open **AWS Console** → Navigate to **S3**.
2. Click **Create bucket**.
3. **Bucket Name**: Enter a unique name (e.g., `demo-app-backend-s3-bucket-1234`).
   - 🚨 **Important**: S3 bucket names must be globally unique across all AWS accounts.

### 2. Configure Bucket Settings
1. Keep **Block Public Access** enabled (for security).
2. Enable **Bucket Versioning** (optional).
3. Click **Create bucket**.


## Part 4: Configure SNS to Send Email Notifications on S3 File Uploads

### 1. Create an SNS Topic
1. Go to **AWS Console** → Navigate to **Amazon SNS**.
2. Click **Topics** → Click **Create topic**.
3. **Type**: Standard.
4. **Name**: `demo-app-sns-topic`.
5. Click **Create topic**.

### 2. Subscribe an Email to the SNS Topic
1. In the **SNS Console**, go to **Topics**.
2. Select **demo-app-sns-topic**.
3. Click **Create subscription**.
4. **Protocol**: Select **Email**.
5. **Endpoint**: Enter your email address (e.g., `your-email@example.com`).
6. Click **Create subscription**.
7. Go to your email and **confirm the subscription** (You will receive an email from AWS SNS—click the confirmation link).

### 3. Update SNS Topic Policy to Allow S3 to Publish
By default, SNS only allows the topic owner to publish messages. To allow S3 to publish events, update the SNS topic policy.

1. Go to **SNS Console** → Click on **demo-app-sns-topic**.
2. Click **Edit** → Scroll down to **Access policy**.
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

🔹 **Replace `YOUR_AWS_ACCOUNT_ID` with your AWS Account ID**.
🔹 Click **Save changes**.

### 4. Configure S3 to Trigger SNS on File Upload
1. Go to **AWS Console** → Navigate to **Amazon S3**.
2. Select the bucket (`demo-app-backend-s3-bucket-1234`).
3. Click **Properties** → Scroll to **Event notifications**.
4. Click **Create event notification**.
5. **Event name**: `demo-app-s3-object-upload-notification`.
6. **Event types**: Select **Object creation (All object create events)**.
7. **Destination**:
   - Choose **SNS topic**.
   - Select **demo-app-sns-topic**.
8. Click **Save changes**.



## Part 5: Create DynamoDB Table and Lambda for File Metadata Extraction & Storage

### 1. Create a DynamoDB Table
Go to AWS Console → DynamoDB → Tables → Create Table  
Table name: demo-app-file-metadata-dynamodb  
Partition Key:  
- Name: file_name  
- Type: String  
Leave all other settings as default  
Click **Create Table**  

🚨 **Important:**  
You don’t need to manually define other attributes (like upload_time, file_size).  
These attributes will be dynamically inserted by the Lambda function when writing data.  
After Lambda writes data, you can see these attributes under **Explore Items** in DynamoDB.  

### 2. Create an IAM Role for Lambda
Go to the IAM Console → Roles → Create role  
Select **AWS Service** → **Lambda** → **Next**  
Attach the following policies:  
- **AmazonS3ReadOnlyAccess** (To read files from S3)  
- **AmazonDynamoDBFullAccess** (To write metadata to DynamoDB)  
- **AWSLambdaBasicExecutionRole** (For CloudWatch logging)  
Create the role and note down the **Role ARN**  
Name: **demo-app-lambda-iam-role**  

### 3. Create a Lambda Function
Go to the Lambda Console → **Create function**  
Choose **Author from Scratch**  
- Enter **Function Name**: demo-app-metadata-lambda  
- Select **Python 3.x** as Runtime  
- Choose **Use an existing role** (demo-app-lambda-iam-role) and select the IAM role created earlier  
Click **Create Function**  

### 4. Subscribe Lambda to Existing SNS Topic
Go to the SNS Console → Your SNS Topic (**demo-app-sns-topic**)  
Click **Create Subscription**  
- Choose **Protocol**: AWS Lambda  
- Select the Lambda Function you created (**demo-app-metadata-lambda**)  
Click **Create Subscription**  
Confirm the subscription in **Lambda Permissions** (IAM might require adding SNS invoke permissions).  

### 5. Update Lambda Code to Process SNS Events
Modify the Lambda function to extract bucket name, file name, and timestamp from the SNS event and store it in the DynamoDB table.  
Go to **Lambda demo-app-metadata-lambda** → **Code** → Paste the following code in it → Click on **Deploy**  

```python
import boto3
import json
import os

# Set the AWS Region (Update with your actual region)
AWS_REGION = "us-east-1"

# Initialize DynamoDB with the region
dynamodb = boto3.resource('dynamodb', region_name=AWS_REGION)

TABLE_NAME = "demo-app-file-metadata-dynamodb"

def lambda_handler(event, context):
   try:
       print("✅ Event received:", json.dumps(event, indent=2))  # Debugging log

       for record in event.get("Records", []):
           # Extract SNS message (which contains the actual S3 event)
           sns_message = record["Sns"]["Message"]
           print("✅ Extracted SNS Message:", sns_message)

           # Parse the SNS message as JSON (contains the actual S3 event)
           s3_event = json.loads(sns_message)

           # Process each S3 record inside the SNS message
           for s3_record in s3_event.get("Records", []):
               s3_info = s3_record.get("s3", {})
               bucket_name = s3_info.get("bucket", {}).get("name")
               file_name = s3_info.get("object", {}).get("key")

               if not bucket_name or not file_name:
                   print("❌ Missing bucket name or file name, skipping record.")
                   continue 

               print(f"✅ Extracted File: {file_name} from Bucket: {bucket_name}")

               # Store in DynamoDB
               table = dynamodb.Table(TABLE_NAME)  # Get the table object

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

### 6. Quick Test
1. Go to the S3 Bucket **demo-app-backend-s3-bucket-1234** (the name might be different for you).
2. Upload any file.
3. Now, you should have received an **Email**.
4. Go to **Lambda demo-app-metadata-lambda**.
5. Click on **Monitor** → **View CloudWatch Logs**.
6. This will take you to CloudWatch Group **/aws/lambda/demo-app-metadata-lambda**.
7. Click on the latest **Logstream** (e.g., `2025/03/05/[$LATEST]d5ca2959b8ba45feb602aae9915f4fce`).
8. At the end of the logs, you will see something like:
   ```
   Extracted File: <your file name> from Bucket: <your bucket name>
   ```

This confirms that:
- Upon uploading a file to **S3**, an **event is sent to the SNS topic**.
- **SNS successfully sends an Email and triggers the Lambda Function**.
- **Lambda writes metadata to the DynamoDB table**. ✅



## Part 6: Step-by-Step Guide to Deploy a Flask Application on Test AMI Builder EC2 with RDS & S3, DynamoDB Integration in Public Subnet

### 1. Create an IAM Role for S3 and DynamoDB Access

1. Go to the AWS IAM Console
2. Click Roles in the left menu
3. Click Create Role
4. **Attach Policies**
   - Select AWS service → EC2 → Next.
   - Attach `AmazonS3FullAccess` and `AmazonDynamoDBReadOnlyAccess` policy.
5. Name the role (e.g., `demo-app-s3-dynamo-iam-role`) and create it.

### 2. Launch a Test and AMI Builder EC2 Instance

1. Go to AWS Management Console → Navigate to EC2.
2. Click **Launch Instance**.
3. Enter an Instance Name (e.g., `demo-app-test-ami-builder`).
4. Choose an AMI:
   - Select Ubuntu 24.04 LTS (or latest available).
5. Choose Instance Type:
   - `t2.micro` (for free-tier) or any other type as required.
6. **Create/Select Key Pair**:
   - If you don’t have a key, click **Create a new key pair**, download it, and keep it safe.
   - Name: `demo-app-private-key`
   - Download `.ppk` for Putty and `.pem` for Terminal.
7. **Network Settings**:
   - Select the VPC where the Test AMI Builder instance should be deployed.
   - Subnet: Choose a **Public Subnet** (e.g., `demo-app-public-subnet-1`).
   - Enable **Auto-Assign Public IP**.
8. **Create a Security Group**:
   - Name: `demo-app-test-ami-builder-sg`
   - Allow **SSH (port 22)** from your IP (or `0.0.0.0/0` for testing but restrict it in production).
   - Allow **5000** from your IP (or `0.0.0.0/0` for testing but restrict it in production). This is required because our sample python app runs on port `5000`.
9. **Assign IAM Role**:
   - Select the IAM role `demo-app-s3-dynamo-iam-role` created in the above step in **Advanced details** → **IAM instance profile**.
10. Click **Launch Instance** and wait for it to start.
11. Copy the **Public IP Address** of the instance.

### 3. Connect to the Test AMI Builder

#### Terminal:
```bash
chmod 400 /path/to/your/key/demo-app-private-key.pem
ssh -i /path/to/your/key/demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>
```
#### Putty:
- Use the `.ppk` file.

Replace `my-key.pem` with your actual key and `<BASTION_PUBLIC_IP>` with the copied IP.

### 4. Install Dependencies

#### Update Packages
```bash
sudo apt update && sudo apt upgrade -y
```

#### Install Required Software
```bash
sudo apt install python3 python3-pip python3-venv git vim -y
```

#### Set Up a Virtual Environment
```bash
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate
```

#### Install Python Packages
```bash
pip install flask pymysql boto3 flask-cors
```

### 5. Deploy Flask Application (Backend - Application Layer)

#### Create Application Directory
```bash
mkdir /home/ubuntu/flask-app
cd /home/ubuntu/flask-app
```

#### Create `app.py`
```bash
vim app.py
```

#### Paste the following Flask application (Modify `RDS_HOST`, `RDS_USER`, `RDS_PASSWORD`, `S3_BUCKET`):
```python
from flask import Flask, request, jsonify
import pymysql
import boto3
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # ✅ Allow all origins

# RDS and S3 Configurations
RDS_HOST = "CHANGE_ME"
RDS_USER = "CHANGE_ME"
RDS_PASSWORD = "CHANGE_ME"
RDS_DATABASE = "demo"
S3_BUCKET = "CHANGE_ME"
DYNAMODB_TABLE_NAME = "demo-app-file-metadata-dynamodb"

# AWS S3 Client
s3_client = boto3.client("s3")

# Create Database if Not Exists
def initialize_database():
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD)
    with conn.cursor() as cursor:
        cursor.execute(f"CREATE DATABASE IF NOT EXISTS {RDS_DATABASE}")
    conn.commit()
    conn.close()

    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)
    with conn.cursor() as cursor:
        cursor.execute(
            """CREATE TABLE IF NOT EXISTS users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL
            )"""
        )
    conn.commit()
    conn.close()

# Connect to RDS
def get_db_connection():
    return pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD, database=RDS_DATABASE)

# API to Insert User into RDS
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

if __name__ == "__main__":
    initialize_database()
    app.run(host="0.0.0.0", port=5000, debug=True)
```

### 6. Deploy HTML+JavaScript Frontend on S3 (Frontend - Presentation Layer)

#### Create an S3 Bucket for Frontend
1. Go to **AWS S3 Console** → **Create a bucket** (e.g., `demo-app-frontend-s3-bucket-6789`).
2. **Disable Block public access**.
3. **Enable Static Website Hosting**:
   - Go to **Properties** → **Static website hosting** → **Edit** → **Enable**.
   - Set **Index document** to `index.html`.
   - **Save changes**.
4. **Set Bucket Policy to Allow Public Read Access**:
   - Go to **Permissions** → **Bucket Policy** → **Edit** → Paste the following policy (change bucket name) → **Save**.

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

# Deploying a Flask Application on AWS

### Step 7: Start the Flask Application
1. SSH into your EC2 instance.
2. Navigate to your application directory and start the Flask app:
   ```bash
   python3 app.py
   ```
3. This may fail with the following error:
   ```
   pymysql.err.OperationalError: (2003, "Can't connect to MySQL server on 'my-demo-db.c66qvyoujzwv.us-east-1.rds.amazonaws.com' (timed out)")
   ```
   This happens because the RDS Security Group (SG) allows connections on Port 3306 only from your public IP.

### Step 8: Update the RDS Security Group
1. Go to the AWS RDS Console.
2. Select the instance **my-demo-db**.
3. Navigate to **Connectivity & Security** → Open the **SG demo-app-db-sg**.
4. In **SG demo-app-db-sg**, go to **Inbound Rules** → Click **Edit Inbound Rules**.
5. Add a new rule:
   - **Port Range:** 3306
   - **Source:** Search for and select **demo-app-test-ami-builder-sg**.
6. Save the changes.

### Step 9: Start the Flask Application Again
1. Try starting the Flask app again:
   ```bash
   python3 app.py
   ```
2. If there are no errors, your backend is now connected to the database.

### Step 10: Access the Application on S3 Bucket
1. Go to the **S3 Bucket** in AWS Console.
2. Navigate to **Properties** → **Static Website Hosting**.
3. Copy the **Bucket website endpoint**.
4. Open the copied URL in a browser and test the application.

This setup ensures your Flask backend runs on EC2, the frontend is hosted on S3, and all components interact correctly.

### Step 11: Configure Flask as a Systemd Service
To ensure the Flask application runs in the background and starts automatically on system reboots, we will create a systemd service.

#### 1. Create a Systemd Service File
```bash
sudo vim /etc/systemd/system/flask-app.service
```

Paste the following content:
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

#### 2. Reload Systemd and Enable the Service
```bash
sudo systemctl daemon-reload
sudo systemctl enable flask-app
```

#### 3. Start the Flask Service
```bash
sudo systemctl start flask-app
```

Check the status:
```bash
sudo systemctl status flask-app
```
If everything is running correctly, you should see output indicating that the service is **active (running)**.

#### 4. Verify the Application
Open a browser and visit the **S3 Static Website URL** to test.

#### 5. Restart the EC2 Instance to Test Auto-Start
```bash
sudo reboot
```

After rebooting, check if the service is running:
```bash
sudo systemctl status flask-app
```


## Part 7: Step-by-Step Guide to Create an AMI, Launch Template, and Auto Scaling Group

Since Launch Configurations are being replaced by Launch Templates, we will use a Launch Template instead. This approach is more flexible, supports multiple versions, and is recommended by AWS.

## 1. Create an AMI from the Running EC2 Instance
We first create an Amazon Machine Image (AMI) so that new instances launched by the Auto Scaling Group (ASG) will have our application pre-installed.

### 1.1 Stop the Flask Application
Before creating an AMI, stop the flask-app service running on `demo-app-test-ami-builder` instance:
```bash
sudo systemctl stop flask-app
```

### 1.2 Create an AMI from the Running Instance
1. Go to AWS Console → EC2 Dashboard
2. Select the running instance
3. Click on **Actions → Image and templates → Create Image**
4. Provide an Image Name (e.g., `demo-app-ami`)
5. Enable **No reboot** (optional but recommended)
6. Click **Create Image**

### 1.3 Verify AMI Creation
1. Navigate to **EC2 Dashboard → AMIs**
2. Wait until the AMI status changes to "available"

---

## 2. Create a Launch Template
A Launch Template defines how instances are launched with predefined configurations.

### 2.1 Open Launch Template Wizard
1. Go to **EC2 Dashboard**
2. Click on **Launch Templates**
3. Click **Create Launch Template**

### 2.2 Configure Launch Template
- **Template Name**: `demo-app-launch-template`
- **AMI ID**: Select the AMI we just created (`demo-app-ami`)
- **Instance Type**: `t2.micro` (or as per requirement)
- **Key pair name**: `demo-app-private-key`
- **Subnet**: Do not select any here; we will select in ASG
- **Create security group**: Do not specify any rule now; we will do that later
  - **Name**: `demo-app-lt-asg-sg`
  - **Description**: Access from Bastion Host and LB
  - **VPC**: Select the `demo-app-vpc` in which the SG will be created.
- **Storage**: Keep default (or modify as needed)  
- **Advanced details → IAM instance profile**: Select the IAM role `demo-app-s3-dynamo-iam-role` with DynamoDB and S3 Access created earlier.
- **Advanced details → User Data**: Add the following script (to start the service on instance launch):

```bash
#!/bin/bash
sudo systemctl start flask-app
sudo systemctl enable flask-app
```

- Click **Review & Create**

---

## 3. Create an Auto Scaling Group (ASG)
The ASG will automatically manage EC2 instances to ensure availability.

### 3.1 Open ASG Wizard
1. Go to **EC2 Dashboard**
2. Click on **Auto Scaling Groups**
3. Click **Create Auto Scaling Group**

### 3.2 Configure ASG
- **Enter ASG Name**: `demo-app-asg`
- **Choose Launch Template**: Select `demo-app-launch-template`
- **Choose VPC and Subnets**: We will create ASG in Private Subnet
  - **VPC**: `demo-app-vpc`
  - **Availability Zones and subnets**:
    - `demo-app-private-subnet-1`
    - `demo-app-private-subnet-2`
    - `demo-app-private-subnet-3`
- **Set Scaling Policies**
  - **Desired Capacity** = `2`
  - **Min Instances** = `2`
  - **Max Instances** = `3`
  - **Automatic scaling** → Target tracking scaling policy
- **Tags**
  - **Key** = `Name`  
  - **Value** = `app-demo-asg-instances`
- Click **Review & Create**
- Click **Create ASG**

---

## 4. Verify ASG Setup

### 4.1 Check if ASG Launches Instances
1. Go to **EC2 Dashboard → Instances**
2. Confirm that new instances are being launched by ASG

### 4.2 Verify New Instances
1. Go to **EC2 Dashboard → Instances**
2. Check the **Launch Time** of the instances to confirm they are newly created.
3. Verify IAM Role is attached to instances.

---

This completes the setup for creating an AMI, Launch Template, and Auto Scaling Group!




## Part 8: Step-by-Step Guide to Attach Load Balancer to Auto Scaling Group (ASG)

### 1. Create a Target Group (TG)
1. Go to AWS Console → Navigate to EC2 Dashboard.
2. On the left panel, click **Target Groups** under **Load Balancing**.
3. Click **Create target group**.
4. Fill in the details:
   - **Choose target type** → Select **Instance**
   - **Target group name** → `demo-app-tg`
   - **Protocol** → HTTP
   - **Port** → 5000 (Your Flask app port)
   - **VPC** → Select the same VPC where your EC2 instances are running (`demo-app-vpc`)
   - **Health check protocol** → HTTP
   - **Health check path** → `/`
5. Click **Next**.
6. **DO NOT** manually register targets (Auto Scaling will handle this).
7. Click **Create target group**.

### 2. Create an Application Load Balancer (ALB)
#### First, Create a Security Group (SG)
1. Go to **EC2** → **Security Groups**.
2. Create a Security Group:
   - **Security group name**: `demo-app-lb-sg`
   - **Description**: `demo-app-lb-sg for public access`
   - **VPC**: Select your VPC → `demo-app-vpc`
   - **Inbound Rule**: 
     - **Port Range**: `80`
     - **Source**: `Anywhere`

#### Create the Load Balancer
1. Go to **EC2 Dashboard** → Click **Load Balancers** to create a Load Balancer.
2. Click **Create Load Balancer**.
3. Select **Application Load Balancer (ALB)**.
4. Configure basic details:
   - **Name** → `demo-app-alb`
   - **Scheme** → `Internet-facing`
   - **IP address type** → `IPv4`
   - **VPC** → Select your VPC.
   - **Availability Zones** → Select AZs with Public Subnets:
     - `demo-app-public-subnet-1`
     - `demo-app-public-subnet-2`
     - `demo-app-public-subnet-3`
5. Configure Security Groups:
   - Use the security group created in the above step: `demo-app-lb-sg`
6. Configure Listeners and Routing:
   - **Listener protocol** → HTTP
   - **Listener port** → `80`
   - **Forward to target group** → Select `demo-app-tg`
7. Click **Create Load Balancer**.

### 3. Attach the Target Group to the Auto Scaling Group (ASG)
1. Go to **AWS Console** → Navigate to **EC2**.
2. Click **Auto Scaling Groups**.
3. Select your **Auto Scaling Group (ASG)**.
4. Click **Edit**.
5. Scroll to **Load balancing** → **Load Balancers**.
6. Tick **Application, Network, or Gateway Load Balancer target groups** and select the Target Group `demo-app-tg`.
7. Click **Update**.

### 4. Verify Load Balancer and ASG Integration
1. Go to **EC2 Dashboard** → Click **Target Groups**.
2. Select `demo-app-tg`.
3. Click on **Targets** → Ensure that ASG instances appear here.
4. Verify that instances show **healthy** status (**This will fail initially**).
5. Go to **ASG Security Group (`demo-app-lt-asg-sg`)**.
6. Edit **Inbound Rules**:
   - Click **Add Rule**.
   - **Port Range**: `5000`
   - **Source**: Custom → Select `demo-app-lb-sg`.
   - Click **Save Rules**.
7. **Test Load Balancer URL**:
   - Go to **Load Balancers** → Click `demo-app-lb`.
   - Copy **DNS Name**.
   - Open a browser → Enter `http://<ALB-DNS-Name>`.
   - Your Flask app should load!

### 5. Update `index.html`
Now that we have created an **ASG** and **Load Balancer**, we should point our **Frontend** to the Load Balancer instead of the EC2 IP:Port.

1. Update `API_BASE` in `index.html` to point to `http://LoadBalancer:80`.
2. Re-upload the updated file to the **S3 Bucket** (e.g., `demo-app-frontend-s3-bucket-6789`).



## Part 9: Create a Bastion Host in Public Subnet to Access Instances in Private Subnet

### 1. Launch an EC2 Instance (Bastion Host)
- Go to AWS Management Console → Navigate to EC2.
- Click **Launch Instance**.
- Enter an Instance Name (e.g., `demo-app-bastion-host`).

#### Choose an AMI:
- Select **Ubuntu 24.04 LTS** (or latest available).

#### Choose Instance Type:
- `t2.micro` (for free-tier) or any other type as required.

#### Create/Select Key Pair:
- If you don’t have a key, click **Create a new key pair**, download it, and keep it safe.
- **Name:** `demo-app-private-key`
- Download **.ppk** for Putty.
- Download **.pem** for Terminal.

### 2. Configure Networking
- **Network:** Select the VPC where the Bastion Host should be deployed.
- **Subnet:** Choose a **Public Subnet** (`demo-app-public-subnet-1`).
- **Enable Auto-Assign Public IP:** Ensure **Auto-assign public IP** is **Enabled**.

### 3. Set Up Security Group
Create a new Security Group (or use an existing one):
- **Name:** `demo-app-bastion-host-sg`
- Allow **SSH (port 22)** from your IP (or `0.0.0.0/0` for testing but restrict it in production).

### 4. Launch the Instance
- Click **Launch Instance** and wait for it to start.
- Copy the **Public IP Address** of the instance.



## Part 10: Connect From Bastion Host to Private Instance

### 1. Copy the Private Key to Bastion Host
#### Using Terminal:
```bash
scp -vvv -i ~/Downloads/demo-app-private-key.pem ~/Downloads/demo-app-private-key.pem ubuntu@18.207.106.246:/home/ubuntu/
```
#### From Windows:
- Use a tool like **WinSCP** and upload the private key to `/home/ubuntu/` directory.

### 2. Update ASG of `demo-app-lt-asg-sg`
- Update `demo-app-lt-asg-sg` security group.
- **Add Rule:**
  - **Port:** 22
  - **Source:** Custom
  - Search for `demo-app-bastion-host-sg` and select it.

### 3. Connect to the Bastion Host
#### Open a terminal or Putty to connect to the Bastion Host (Instance) via SSH:
#### Terminal:
```bash
chmod 400 demo-app-private-key.pem
ssh -i demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>
```
#### Putty:
- Use the `.ppk` file.

> Replace `demo-app-private-key.pem` with your actual key and `<BASTION_PUBLIC_IP>` with the copied IP.

🚀 Your Bastion Host is ready to access private instances securely!

### 4. You are in Bastion Host
- You should be able to see the private key copied in `/home/ubuntu`:
```bash
ls -l
```
- Go to the **AWS Console** → **EC2 Instance**.
- Select one of the instances created by the ASG.
- Get its **private IP**.

#### Try SSH:
```bash
ssh -i "demo-app-private-key.pem" ubuntu@<EC2_PRIVATE_IP>
```

### Now you are in the Private App Instance
#### Install netstat command to debug anything:
```bash
sudo apt install net-tools
```
#### Check logs:
```bash
sudo journalctl -u flask-app.service -n 50 --no-pager
```
#### Stop and Start Flask App Service:
```bash
sudo systemctl stop flask-app
sudo systemctl start flask-app
sudo systemctl status flask-app
```
#### Check logs again:
```bash
sudo journalctl -u flask-app.service -n 50 --no-pager
```


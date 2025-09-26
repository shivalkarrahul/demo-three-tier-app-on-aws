# Three-Tier Application on AWS

This repository contains step-by-step instructions to set up a three-tier application on AWS.  
It is written for beginners and college students, with clear redundancy so that no prior AWS knowledge is required.

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




---

## Part 1: Network Setup

### 1. Create a VPC
1. Go to **AWS Console → VPC Dashboard**.  
2. Click **Create VPC**.  
3. Enter:  
   - **Name:** `demo-app-vpc`  
   - **IPv4 CIDR Block:** `10.0.0.0/16`  
4. Click **Create VPC**.

---

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

---

### 3. Create & Attach Internet Gateway (IGW)
1. Go to **Internet Gateways → Create Internet Gateway**.  
2. Enter:  
   - **Name:** `demo-app-igw`  
3. Click **Create**.  
4. Select `demo-app-igw` → Click **Actions → Attach to VPC**.  
5. Choose **VPC:** `demo-app-vpc` → Click **Attach**.

---

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

### 5. Create NAT Gateways (One per Private Subnet)

#### Allocate Elastic IPs
1. Go to **Elastic IPs → Allocate Elastic IP → Allocate**.  
2. Repeat 2 more times (Total: **3 Elastic IPs**).  

#### Create 3 NAT Gateways (One in Each Public Subnet)
1. Go to **NAT Gateways → Create NAT Gateway**.  
2. Create:  
   - **demo-app-nat-gateway-1**  
     - Subnet: `demo-app-public-subnet-1`  
     - Elastic IP: (Select first one)  
   - **demo-app-nat-gateway-2**  
     - Subnet: `demo-app-public-subnet-2`  
     - Elastic IP: (Select second one)  
   - **demo-app-nat-gateway-3**  
     - Subnet: `demo-app-public-subnet-3`  
     - Elastic IP: (Select third one)  
3. Click **Create**.  

⚠️ **Note:** Wait until all NAT Gateways are created before proceeding.

---

### 6. Create Separate Route Tables for Each Private Subnet

#### Route Table for Private Subnet 1
1. Go to **Route Tables → Create Route Table**.  
2. Enter:  
   - **Name:** `demo-app-private-rt-1`  
   - **VPC:** `demo-app-vpc`  
3. Click **Create**.  
4. Select `demo-app-private-rt-1` → **Edit Routes**.  
5. Add Route:  
   - **Destination:** `0.0.0.0/0`  
   - **Target:** NAT → `demo-app-nat-gateway-1`  
6. Click **Save Routes**.  
7. Go to **Subnet Associations → Edit Subnet Associations**.  
8. Select:  
   - ✅ `demo-app-private-subnet-1`  
9. Click **Save Associations**.

---

#### Route Table for Private Subnet 2
1. Go to **Route Tables → Create Route Table**.  
2. Enter:  
   - **Name:** `demo-app-private-rt-2`  
   - **VPC:** `demo-app-vpc`  
3. Click **Create**.  
4. Select `demo-app-private-rt-2` → **Edit Routes**.  
5. Add Route:  
   - **Destination:** `0.0.0.0/0`  
   - **Target:** NAT → `demo-app-nat-gateway-2`  
6. Click **Save Routes**.  
7. Go to **Subnet Associations → Edit Subnet Associations**.  
8. Select:  
   - ✅ `demo-app-private-subnet-2`  
9. Click **Save Associations**.

---

#### Route Table for Private Subnet 3
1. Go to **Route Tables → Create Route Table**.  
2. Enter:  
   - **Name:** `demo-app-private-rt-3`  
   - **VPC:** `demo-app-vpc`  
3. Click **Create**.  
4. Select `demo-app-private-rt-3` → **Edit Routes**.  
5. Add Route:  
   - **Destination:** `0.0.0.0/0`  
   - **Target:** NAT → `demo-app-nat-gateway-3`  
6. Click **Save Routes**.  
7. Go to **Subnet Associations → Edit Subnet Associations**.  
8. Select:  
   - ✅ `demo-app-private-subnet-3`  
9. Click **Save Associations**.

---

✅ **At this point, your VPC, subnets, internet gateway, NAT gateways, and route tables are fully set up.**  
This forms the foundation of the three-tier architecture.



---

## Part 2: Set Up RDS

### 1. Create an RDS Instance
1. Open **AWS Management Console → RDS**.  
2. Click **Create database**.  
3. Choose **Standard create**.  
4. Select **MySQL** as the database engine.  
5. Select **Free tier** to avoid charges.

---

### 2. Configure Database Settings
1. Set **DB instance identifier:** `my-demo-db`  
2. Set **Master username:** `admin`  
3. Set **Master password:** Choose a strong password and **note it down** somewhere safe.

---

### 3. Configure Storage
1. **Storage type:** General Purpose (SSD)  
2. **Allocated storage:** 20 GiB  
3. Keep **storage auto-scaling enabled** in Additional storage configuration.

---

### 4. Configure Connectivity
1. **VPC:** Select the VPC created earlier (`demo-app-vpc`).  
2. **Subnet group:** Select **Create new DB subnet group**.  
3. **Public access:** Select **No** (RDS should **not** be publicly accessible).  
4. **VPC security groups:**  
   - Click **Create new security group**  
   - Name: `demo-app-db-sg`

---

### 5. Create the RDS Instance
1. Click **Create database**.  
2. Wait for the RDS instance to reach **Available** status before proceeding.  

✅ **At this point, your MySQL RDS instance is ready and securely placed in your private subnets.**


## Part 3: Set Up S3

This bucket will be used for backend purposes. Files uploaded to the demo-app will be stored here.

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

## Part 4: Configure SNS to Send Email Notifications on S3 File Uploads

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


## Part 5: Create DynamoDB Table and Lambda for File Metadata Extraction & Storage

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

1. Upload a file to your S3 bucket (e.g., `demo-app-backend-s3-bucket-1234`).
2. You should receive an email notification from SNS.
3. Go to **Lambda → demo-app-metadata-lambda → Monitor → View CloudWatch Logs**.
4. Open the latest log stream.
5. You should see a log entry like:

```
Extracted File: <your file name> from Bucket: <your bucket name>
```

✅ This confirms that uploading a file to S3 triggers SNS, which sends an email, invokes Lambda, and writes metadata to DynamoDB successfully.


## Part 6: Deploy a Flask Application on Test AMI Builder EC2 with RDS & S3, DynamoDB Integration in Public Subnet

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


## Part 7: Create an AMI, Launch Template, and Auto Scaling Group

Since Launch Configurations are being replaced by Launch Templates, we will use a Launch Template instead. This approach is more flexible, supports multiple versions, and is recommended by AWS.

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

---

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

---

### 4. Verify ASG Setup

#### 4.1 Check if ASG Launches Instances

* Go to **EC2 Dashboard → Instances**
* Confirm that new instances are being launched by the ASG

#### 4.2 Verify New Instances

* Check the **Launch Time** of the instances to confirm they are newly created
* Verify that the **IAM Role** (`demo-app-s3-dynamo-iam-role`) is attached to the instances


## Part 8: Attach Load Balancer to Auto Scaling Group (ASG)

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

---

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

---

### 3. Attach the Target Group to the Auto Scaling Group (ASG)
1. Go to EC2 → **Auto Scaling Groups**  
2. Select your ASG  
3. Click **Edit**  
4. Scroll to **Load balancing → Load Balancers**  
5. Tick **Application, Network or Gateway Load Balancer target groups**  
6. Select the target group `demo-app-tg`  
7. Click **Update**

---

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

---

### 5. Update `index.html`
Since the frontend is hosted on S3 and the backend is now behind the ALB:  
1. Update `API_BASE` in `index.html` to point to `http://<ALB-DNS-Name>:80`  
2. Re-upload `index.html` to the frontend S3 bucket (e.g., `demo-app-frontend-s3-bucket-6789`)  
3. Access the S3 website URL and verify the frontend connects to the backend via the ALB


## Part 9: Create a Bastion Host in Public Subnet to Access Instances in Private Subnet

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

---

### 2. Configure Networking
- **Network:** Select the VPC where the Bastion Host should be deployed  
- **Subnet:** Select a Public Subnet (`demo-app-public-subnet-1`)  
- **Auto-Assign Public IP:** Enabled  

---

### 3. Set Up Security Group
- Create a new SG or use an existing one:  
  - **Name:** `demo-app-bastion-host-sg`  
  - **Inbound Rule:** Allow SSH (port 22) from your IP (or 0.0.0.0/0 for testing; restrict in production)  

---

### 4. Launch the Instance
- Click **Launch Instance** and wait for it to start  
- Copy the **Public IP Address** of the Bastion Host  

---

### ⚠️ Note
After creating the Auto Scaling Group (ASG) with a new Launch Template and SG, the ASG instances may fail to connect to the RDS because the new SG is not allowed in the RDS SG.  

**To fix this:**  
1. Update the **RDS Security Group** to allow inbound access from the new ASG SG.  
2. Delete the existing ASG instances.  
3. Let the ASG launch new instances — they will now connect to RDS successfully and the application will work correctly.


111

## Part 10: Connect From Bastion Host to Private Instance

### 1. Copy the Private Key to Bastion Host
**From Terminal (Linux/Mac):**  
```bash
scp -vvv -i ~/Downloads/demo-app-private-key.pem ~/Downloads/demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>:/home/ubuntu/
```

**From Windows:**

* Use a tool like **WinSCP** and upload the private key to `/home/ubuntu/` directory on the Bastion Host.

---

### 2. Update ASG Security Group

* Update the ASG security group `demo-app-lt-asg-sg`
* Add an **Inbound Rule:**

  * **Port:** 22
  * **Source:** Custom → select `demo-app-bastion-host-sg`

---

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

---

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

---

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

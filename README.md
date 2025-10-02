# From Hello World to Real World: A Hands-On Journey into Event-Driven Three-Tier Architecture on AWS

**Presenter:** Rahul Shivalkar

**Event:** AWS Cloud Club - MIT ADTU and AWS Cloud Club MIT-WPU

This intensive, hands-on workshop is designed for developers and cloud enthusiasts ready to move beyond basic setups and deploy a truly **scalable, secure, and production-ready three-tier application on AWS**.

**Workshop Flow:**

1. **Network Foundation:**

   * Build a robust custom VPC with Public and Private Subnets.
   * Configure NAT Gateways and a secure Bastion Host for management access.

2. **Backend Deployment & HA:**

   * Deploy a Flask backend application.
   * Ensure High Availability (HA) using an Application Load Balancer (ALB) distributing traffic across an Auto Scaling Group (ASG).

3. **Data Security & Event-Driven Integration:**

   * Secure the data layer by placing RDS (MySQL) in private subnets.
   * Implement an **event-driven pipeline**:

     * File uploads to S3 trigger SNS notifications.
     * AWS Lambda functions process metadata and store it in DynamoDB.

**Outcome:**
By the end of this workshop, attendees will have the practical skills and confidence to **design, deploy, and scale complex applications** using core AWS best practices in **networking, security, and serverless integration**.

---

<details>
<summary>Presentation</summary>

## Agenda

1. Introduction: Why event-driven, three-tier architectures matter
2. Three-Tier Architecture Overview
3. AWS Services & Event-Driven Design
4. Lambda & Serverless Integration
5. Storage & Data Flow
6. Application Layer: Flask on EC2
7. Monitoring & Notifications
8. Demo & Key Learnings

---

## Introduction

* Many applications start as simple scripts or “Hello World” apps.
* To be **production-ready**, they need to be scalable, decoupled, and event-driven.
* Event-driven design allows services to **react automatically to events**, reducing manual intervention.
* We focus on AWS services that make it easy to **build, monitor, and scale** applications efficiently.

---

## Three-Tier Architecture Overview

The **architecture is divided into three primary layers**:

1. **Presentation Layer (Frontend)**

   * Handles user interaction and requests.
   * Deployed via Application Load Balancer (ALB) routing traffic to the backend.

2. **Application Layer (Backend & Event-Driven Processing)**

   * Flask backend application deployed on EC2 Auto Scaling Group for High Availability (HA).
   * Event-driven integration components:

     * **S3**: for file uploads
     * **SNS**: for notifications
     * **Lambda**: for processing events and metadata
     * **DynamoDB**: stores processed metadata and supports serverless data operations

3. **Data Layer (Relational Database)**

   * **RDS (MySQL)** deployed in private subnets for secure and persistent storage.

**Note:** DynamoDB is used as part of the event-driven application workflow, complementing the main relational database but does not constitute a separate tier.

**Architecture Diagram:**
![Three-Tier AWS Architecture](artifacts/demo-three-tier-app-on-aws.svg)

---

## Slide: AWS Services & Roles

| AWS Service                           | Role / Purpose in the Architecture                                                   |
| ------------------------------------- | ------------------------------------------------------------------------------------ |
| **VPC**                               | Provides an isolated network for the application. Hosts public and private subnets.  |
| **Public Subnets**                    | Hosts ALB and Bastion Host. Enables controlled access from the Internet.             |
| **Private Subnets**                   | Hosts EC2 backend instances, RDS database, and Lambda (via VPC endpoints if needed). |
| **NAT Gateway**                       | Allows private subnet instances to access the Internet securely (e.g., for updates). |
| **Bastion Host**                      | Secure access point to manage private EC2 instances.                                 |
| **EC2 (Auto Scaling Group)**          | Runs the Flask backend application with High Availability.                           |
| **Application Load Balancer (ALB)**   | Distributes incoming traffic across backend EC2 instances.                           |
| **RDS (MySQL)**                       | Primary relational database for application data, deployed in private subnets.       |
| **S3**                                | Stores uploaded files; triggers event-driven processing.                             |
| **SNS (Simple Notification Service)** | Sends notifications on S3 events to Lambda or other subscribers.                     |
| **Lambda**                            | Processes S3-triggered events, extracts metadata, and stores it in DynamoDB.         |
| **DynamoDB**                          | Stores processed metadata for serverless, scalable storage.                          |
| **Security Groups**                   | Controls inbound and outbound traffic for EC2, RDS, ALB, and Lambda.                 |
| **IAM Roles**                         | Provides permissions for Lambda, EC2, RDS, and other services to interact securely.  |
| **CloudWatch**                        | Monitors application, logs, and triggers alarms for metrics.                         |

**Summary:**
This setup ensures a **secure, scalable, and event-driven three-tier architecture**, combining **traditional relational data storage** with **serverless event processing**.

---

## Application Layer: Flask on EC2

* Flask backend runs on EC2, serving API endpoints.
* Handles CRUD operations on RDS (users, products, orders).
* Accepts file uploads to S3.
* Integrates with Lambda for event-driven processing.
* Ensures **security and isolation** via IAM roles.

**Key Advantage:** Combines **traditional server-based architecture** with serverless event-driven components.

---

## Event-Driven Design with Lambda

**Event Flow:**
`User → S3 → Lambda → DynamoDB → SNS → User`

**Steps:**

1. **Trigger Event:** File uploaded to S3 bucket.
2. **Processing:** Lambda function validates and processes the file.
3. **Database Update:** Updates DynamoDB metadata to track status.
4. **Notification:** Sends alerts to users/admins via SNS.

**Benefits:**

* Immediate response to events.
* Reduces load on EC2 backend.
* Improves reliability by decoupling components.

---

## Storage & Data Flow

* **S3 Bucket:** Stores uploaded files securely.
* **Lambda Function:** Acts as a processor and orchestrator.
* **DynamoDB Table:** Keeps metadata and event logs for tracking.
* **SNS Topic:** Sends real-time notifications to stakeholders.

**Outcome:** A **highly responsive, event-driven system** with minimal manual intervention.

---

## Monitoring & Notifications

* **CloudWatch Logs & Metrics:** Monitor EC2, Lambda, and RDS.
* **SNS Alerts:** Notifies developers or admins of failures or key events.

**Benefits:**

* Quick troubleshooting.
* Proactive system monitoring.
* Reduces downtime and manual checks.

---

## Demo Flow

1. **User uploads a file → S3 bucket**

   * The file is securely stored in S3 for processing.

2. **Lambda function triggers → processes the file**

   * Extracts metadata or transforms data as needed.

3. **RDS updates → relational data storage**

   * Stores structured relational data (e.g., new users via Flask APIs).

4. **DynamoDB updates → metadata and processing status**

   * Serverless storage for quick access to processing results and metadata.

5. **SNS sends notification → user/admin receives an email alert**

   * Alerts stakeholders that file processing is complete.

6. **Flask frontend shows updated data → reflects processed files**

   * Reads from RDS/DynamoDB to show real-time status to users.

---

## Key Takeaways

* Hybrid architecture using **EC2 + Lambda**.
* Event-driven design ensures **automatic, real-time processing**.
* Decoupled services allow **independent scaling** and reliability.
* Demonstrates a **production-ready system** suitable for enterprise applications.

<p align="left"><b>🔒 Presentation section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---



## Hands-On Lab: Deploying the Three-Tier AWS Application

> **Context:** All the following steps are performed in the **us-east-1** (N. Virginia) region.

---

## Who This Guide Is For
This guide is intended for students and developers who want to **learn hands-on AWS deployment** using a three-tier architecture.  

---

## Prerequisites
- AWS Account with appropriate permissions  
- Basic Linux & SSH knowledge  
- Familiarity with Python and Flask

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
- [Part 9: Security Groups Overview](#part-9-security-groups-overview)
- [Part 10: Create a Bastion Host in Public Subnet to Access Instances in Private Subnet](#part-10-create-a-bastion-host-in-public-subnet-to-access-instances-in-private-subnet)
- [Part 11: Connect From Bastion Host to Private Instance](#part-11-connect-from-bastion-host-to-private-instance)
- [Part 12: Cleanup – Terminate All Resources](#part-12-cleanup--terminate-all-resources)

---

## Architecture Diagram - Three-Tier Architecture Overview
![Three-Tier AWS Architecture](artifacts/demo-three-tier-app-on-aws.svg)

## Part 1: Network Setup



### 📖 Theory
<details> <summary>Understanding the Resource</summary> 

> Understand why this resource is needed and how it fits into the AWS architecture before creating it.

In this section, we build the **foundation of the three-tier architecture** on AWS:

- **VPC:** Isolated network for your application.  
- **Subnets:** Public subnets for Load Balancers & NAT, private subnets for app and database layers.  
- **Internet Gateway & NAT Gateways:** Provide controlled internet access for resources.  
- **Route Tables:** Ensure secure and proper traffic routing between subnets and the internet.  

By completing this step, your AWS environment will be ready to securely host the application and database layers.

---

#### Detailed Explanation

**VPC (Virtual Private Cloud):**  
Think of the VPC as your own **virtual data center** inside AWS. It’s a completely isolated network where you define IP ranges, subnets, and routing. This ensures security and control over your infrastructure.

**Subnets:**  
Within the VPC, subnets logically partition the network.  
- **Public Subnets:** For resources that need internet access (Load Balancer, Bastion Host). Connected to the **Internet Gateway (IGW)**.  
- **Private Subnets:** For sensitive resources (application servers, databases). These subnets have **no direct internet access**, which reduces the attack surface.

**Internet Gateway (IGW) & NAT Gateway:**  
- The **IGW** connects public subnets to the internet.  
- The **NAT Gateway** allows private subnet resources to **initiate outbound traffic** (e.g., for updates) while blocking **inbound traffic** from the internet.

**Route Tables:**  
These act as **rules for traffic flow**:  
- Public Route Table → Routes traffic from public subnets to the IGW.  
- Private Route Table → Routes traffic from private subnets to the NAT Gateway.  

---

✅ **Note:**
* We use 1 NAT Gateway and 1 private route table for simplicity and cost-saving. Production should use one per AZ for high availability.
* NAT Gateways incur charges — one is enough for demos.
* After this step, your **VPC, subnets, Internet Gateway, NAT Gateways, and route tables** are fully configured — forming the foundation of your three-tier architecture.


---

✅ **Why this matters:**  
This layered setup enforces **security, availability, and scalability**. Public resources stay accessible, private resources remain protected, and traffic flows are tightly controlled.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 🖥️ AWS Console (Old School Way – Clicks & GUI)
<details> <summary>Create and Configure the Resource via AWS Console</summary> 

> Follow these steps in the AWS Console to create and configure the resource manually.

### 1. Create a VPC
1. Go to **AWS Console → VPC Dashboard**.  
2. Click **Create VPC**. 
3. Select `VPC only`option under **Resources to create** 
4. Enter:  
   - **Name tag:** `demo-app-vpc`  
   - **IPv4 CIDR Block:** `10.0.0.0/16`
5. Keep all other settings as **default**.     
6. Click **Create VPC**.

You could make it a bit lighthearted like this:



### 2. Create Public & Private Subnets

#### 2.1 Public Subnets (For Load Balancer & NAT Gateways)
1. Go to **Subnets → Create Subnet**.  
2. Choose **VPC:** `demo-app-vpc`.  
3. Create three public subnets: (Use the **“Add subnet”** option to create **3 subnets at a time**:)  
   - `demo-app-public-subnet-1` → `10.0.1.0/24` → **us-east-1a**  
   - `demo-app-public-subnet-2` → `10.0.2.0/24` → **us-east-1b**  
   - `demo-app-public-subnet-3` → `10.0.3.0/24` → **us-east-1c**  
4. Click **Create**.

#### 2.2  Private Subnets (For App & DB Layers)
1. Go to **Subnets → Create Subnet**.  
2. Choose **VPC:** `demo-app-vpc`.  
3. Create three private subnets: (Use the **“Add subnet”** option to create **3 subnets at a time**:)  
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

### 4. Create & Configure Public Route Table

#### 4.1 Public Route Table (For Public Subnets)
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

### 5. Create a NAT Gateway

In this step, we will create NAT Gateways to allow instances in private subnets to access the internet for updates and downloads.

This setup uses **a single NAT Gateway** for all private subnets to save costs.

#### 5.1 Allocate Elastic IP

1. Go to **Elastic IPs** in AWS Console.
2. Click **Allocate Elastic IP → Allocate** (allocate **1 Elastic IP**).
3. Click **Tags → Add new tag**:  
   - **Key:** `Name`
   - **Value:** `demo-app-eip-1`

---

#### 5.2 Create NAT Gateway

1. Go to **NAT Gateways → Create NAT Gateway**.
2. Enter:

   * **Name:** `demo-app-nat-gateway-1`
   * **Subnet:** `demo-app-public-subnet-1`
   * **Elastic IP:** Select the `demo-app-eip-1` Elastic IP you allocated
3. Click **Create NAT Gateway**.
4. Wait until the status shows **Available**.

✅ This NAT Gateway will be used for all private subnets.

---

✅ **Note:** Proceed to the next step (creating private route tables) only after the NAT Gateway shows **Available**.

### 6. Create Route Tables for Private Subnets

In this step, we will create route tables to direct traffic from private subnets to the internet via NAT Gateways.


This setup uses **one NAT Gateway** for all private subnets → only **one route table** is needed.

#### 6.1 Create Route Table

1. Go to **Route Tables → Create Route Table**.
2. Enter:

   * **Name:** `demo-app-private-rt-1`
   * **VPC:** `demo-app-vpc`
3. Click **Create**.

#### 6.2 Edit Routes

1. Select `demo-app-private-rt-1` → **Edit Routes**.
2. Add Route:

   * **Destination:** `0.0.0.0/0`
   * **Target:** NAT → `demo-app-nat-gateway-1`
3. Click **Save Routes**.

#### 6.3 Associate Subnets

1. Go to **Subnet Associations → Edit Subnet Associations**.
2. Select:

   * ✅ `demo-app-private-subnet-1`
   * ✅ `demo-app-private-subnet-2`
   * ✅ `demo-app-private-subnet-3`
3. Click **Save Associations**.

✅ All private subnets now use the same NAT Gateway via this route table.

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)
<details> <summary>Run commands to create/configure the resource via CLI</summary> 

> Run these AWS CLI commands to quickly create and configure the resource without navigating the Console.

---

### 1. Create a VPC

```bash
echo "Creating VPC: demo-app-vpc"
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 10.0.0.0/16 \
    --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=demo-app-vpc}]' \
    --query "Vpc.VpcId" --output text --no-cli-pager)

if [ -n "$VPC_ID" ]; then
    echo "✅ VPC created: $VPC_ID"
else
    echo "⚠️ Failed to create VPC demo-app-vpc"
fi
```

---

### 2. Create Public Subnets

```bash
declare -A PUBLIC_SUBNETS=(
    ["demo-app-public-subnet-1"]="10.0.1.0/24:us-east-1a"
    ["demo-app-public-subnet-2"]="10.0.2.0/24:us-east-1b"
    ["demo-app-public-subnet-3"]="10.0.3.0/24:us-east-1c"
)

for name in "${!PUBLIC_SUBNETS[@]}"; do
    IFS=":" read -r CIDR AZ <<< "${PUBLIC_SUBNETS[$name]}"
    echo "Creating Public Subnet: $name in $AZ"
    
    SUBNET_ID=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block $CIDR \
        --availability-zone $AZ \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$name}]" \
        --query "Subnet.SubnetId" --output text --no-cli-pager)
    
    if [ -n "$SUBNET_ID" ]; then
        echo "✅ Subnet created: $name ($SUBNET_ID)"
    else
        echo "⚠️ Failed to create subnet $name"
    fi
done
```
---

### 3. Create Private Subnets

```bash
declare -A PRIVATE_SUBNETS=(
    ["demo-app-private-subnet-1"]="10.0.11.0/24:us-east-1a"
    ["demo-app-private-subnet-2"]="10.0.12.0/24:us-east-1b"
    ["demo-app-private-subnet-3"]="10.0.13.0/24:us-east-1c"
)

for name in "${!PRIVATE_SUBNETS[@]}"; do
    IFS=":" read -r CIDR AZ <<< "${PRIVATE_SUBNETS[$name]}"
    echo "Creating Private Subnet: $name in $AZ"
    
    SUBNET_ID=$(aws ec2 create-subnet \
        --vpc-id $VPC_ID \
        --cidr-block $CIDR \
        --availability-zone $AZ \
        --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$name}]" \
        --query "Subnet.SubnetId" --output text --no-cli-pager)
    
    if [ -n "$SUBNET_ID" ]; then
        echo "✅ Private Subnet created: $name ($SUBNET_ID)"
    else
        echo "⚠️ Failed to create private subnet $name"
    fi
done
```

---

### 4. Create & Attach Internet Gateway (IGW)

```bash
echo "Creating Internet Gateway: demo-app-igw"
IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=demo-app-igw}]' \
    --query "InternetGateway.InternetGatewayId" --output text --no-cli-pager)

if [ -n "$IGW_ID" ]; then
    echo "✅ IGW created: $IGW_ID"
    echo "Attaching IGW to VPC: $VPC_ID"
    aws ec2 attach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --no-cli-pager
    echo "✅ IGW attached to VPC"
else
    echo "⚠️ Failed to create Internet Gateway"
fi
```

---

### 5. Create & Configure a Public Route Table

```bash
echo "Creating Public Route Table: demo-app-public-rt"
PUBLIC_RT_ID=$(aws ec2 create-route-table \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=demo-app-public-rt}]' \
    --query "RouteTable.RouteTableId" --output text --no-cli-pager)

if [ -n "$PUBLIC_RT_ID" ]; then
    echo "✅ Public Route Table created: $PUBLIC_RT_ID"

    # Add route to IGW
    aws ec2 create-route --route-table-id $PUBLIC_RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --no-cli-pager
    echo "✅ Route added to Internet Gateway"

    # Associate with public subnets
    for name in "${!PUBLIC_SUBNETS[@]}"; do
        SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$name" --query "Subnets[0].SubnetId" --output text --no-cli-pager)
        aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $PUBLIC_RT_ID --no-cli-pager
        echo "✅ Public Subnet $name associated with Route Table"
    done
else
    echo "⚠️ Failed to create public route table"
fi

```

---

### 6. Create a NAT Gateway

```bash
# 1️⃣ Allocate Elastic IP for NAT Gateway
echo "Allocating Elastic IP for NAT Gateway: demo-app-eip-1"
EIP_ALLOC_ID=$(aws ec2 describe-addresses --filters "Name=tag:Name,Values=demo-app-eip-1" --query "Addresses[0].AllocationId" --output text)

if [ "$EIP_ALLOC_ID" != "None" ] && [ -n "$EIP_ALLOC_ID" ]; then
    echo "⚠️ Elastic IP already exists: $EIP_ALLOC_ID"
else
    EIP_ALLOC_ID=$(aws ec2 allocate-address \
        --domain vpc \
        --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=demo-app-eip-1}]' \
        --query 'AllocationId' --output text)
    echo "✅ Elastic IP allocated: $EIP_ALLOC_ID"
fi
```

---

### 7. Create Route Tables for Private Subnets

```bash
# Fetch Public Subnet ID
echo "Fetching Public Subnet ID: demo-app-public-subnet-1"
PUBLIC_SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=demo-app-public-subnet-1" \
    --query "Subnets[0].SubnetId" --output text)

if [ "$PUBLIC_SUBNET_ID" == "None" ] || [ -z "$PUBLIC_SUBNET_ID" ]; then
    echo "❌ Public subnet demo-app-public-subnet-1 not found. Aborting NAT Gateway creation."
    exit 1
else
    echo "✅ Public Subnet ID: $PUBLIC_SUBNET_ID"
fi
```

```bash
# Create NAT Gateway
echo "Creating NAT Gateway: demo-app-nat-gateway-1"
NAT_ID=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=demo-app-nat-gateway-1" --query "NatGateways[?State=='available'].NatGatewayId | [0]" --output text)

if [ "$NAT_ID" != "None" ] && [ -n "$NAT_ID" ]; then
    echo "⚠️ NAT Gateway already exists and is available: $NAT_ID"
else
    NAT_ID=$(aws ec2 create-nat-gateway \
        --subnet-id $PUBLIC_SUBNET_ID \
        --allocation-id $EIP_ALLOC_ID \
        --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=demo-app-nat-gateway-1}]' \
        --query 'NatGateway.NatGatewayId' --output text)
    echo "✅ NAT Gateway created: $NAT_ID"
fi
```

```bash
# Wait until NAT Gateway is available
echo "Waiting for NAT Gateway to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_ID --no-cli-pager
echo "✅ NAT Gateway is available"
```

```bash
echo "Creating Private Route Table: demo-app-private-rt-1"
PRIVATE_RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=demo-app-private-rt-1" --query "RouteTables[0].RouteTableId" --output text)

if [ "$PRIVATE_RT_ID" != "None" ] && [ -n "$PRIVATE_RT_ID" ]; then
    echo "⚠️ Private Route Table already exists: $PRIVATE_RT_ID"
else
    PRIVATE_RT_ID=$(aws ec2 create-route-table \
        --vpc-id $VPC_ID \
        --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=demo-app-private-rt-1}]' \
        --query 'RouteTable.RouteTableId' --output text)
    echo "✅ Private Route Table created: $PRIVATE_RT_ID"
fi
```

```bash
# Create Route to NAT Gateway
ROUTE_EXISTS=$(aws ec2 describe-route-tables --route-table-ids $PRIVATE_RT_ID --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'].NatGatewayId" --output text)

if [ "$ROUTE_EXISTS" == "$NAT_ID" ]; then
    echo "⚠️ Route to NAT Gateway already exists in Private Route Table $PRIVATE_RT_ID"
else
    aws ec2 create-route \
        --route-table-id $PRIVATE_RT_ID \
        --destination-cidr-block 0.0.0.0/0 \
        --nat-gateway-id $NAT_ID --no-cli-pager
    echo "✅ Route created via NAT Gateway: $NAT_ID"
fi
```

```bash
# Associate Private Subnets with Route Table
echo "Associating private subnets with Private Route Table"
PRIVATE_SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=demo-app-private-subnet-1,demo-app-private-subnet-2,demo-app-private-subnet-3" \
    --query "Subnets[].SubnetId" --output text)
echo "Private Subnet IDs: $PRIVATE_SUBNET_IDS"

for SUBNET_ID in $PRIVATE_SUBNET_IDS; do
    ASSOCIATED=$(aws ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$SUBNET_ID" --query "RouteTables[0].RouteTableId" --output text)
    if [ "$ASSOCIATED" == "$PRIVATE_RT_ID" ]; then
        echo "⚠️ Subnet $SUBNET_ID already associated with Private Route Table $PRIVATE_RT_ID"
    else
        aws ec2 associate-route-table --route-table-id $PRIVATE_RT_ID --subnet-id $SUBNET_ID --no-cli-pager
        echo "✅ Associated subnet $SUBNET_ID with Private Route Table $PRIVATE_RT_ID"
    fi
done
```

</details>

---

### ✅ Validation (Check if Resource Created Correctly)
<details> <summary>Validate the Resource</summary> 

> After creating resources (either via AWS Console or AWS CLI), validate them using the pre-built script.
> Run the following in CloudShell:

```bash
# Download the validation script from GitHub
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/resource-validation-scripts/1-validate-vpc.sh

# Make it executable
chmod +x 1-validate-vpc.sh

# Run the script
./1-validate-vpc.sh

```

</details>

---


## Part 2: Set Up RDS

### 📖 Theory
<details> <summary>Understanding the Resource</summary> 

> Understand why this resource is needed and how it fits into the AWS architecture before creating it.


In this step, we create a **MySQL RDS instance** to store the application’s data.  

- The database will hold **user information** (e.g., names, IDs, orders, etc.).  
- The RDS instance is placed in **private subnets** for security, ensuring only the **application layer** can access it.  
- After this step, the database is ready to support the backend of your three-tier application.  

---

#### Detailed Explanation

**Database in Multi-Tier Architecture:**  
The database is the **core of any application**. Separating it into a dedicated data layer ensures **security, maintainability, and scalability**.  

**Amazon RDS (Relational Database Service):**  
AWS RDS is a **fully managed service** that handles:  
- Automatic backups  
- Patching and updates  
- Failover and replication  
- Scaling (vertical and horizontal)  

This removes the burden of infrastructure management, letting you focus on your **application data and logic**.  

**Why Private Subnets?**  
- The RDS instance is placed in **private subnets**, meaning it **cannot be accessed directly** from the internet.  
- Only **application servers** in the private subnets can connect to it.  
- This is a **critical security measure** that prevents unauthorized access.  

**Database Subnet Group:**  
When creating RDS, you must specify a **DB Subnet Group**. This ensures AWS deploys the database across your chosen **private subnets** for high availability and isolation.  

---

✅ **Why this matters:**  
Placing the database in private subnets enforces **security best practices** while RDS ensures **operational efficiency**. Together, they form a **secure and reliable data layer** for your application.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 🖥️ AWS Console (Old School Way – Clicks & GUI)
<details> <summary>Create and Configure the Resource via AWS Console</summary> 

> Follow these steps in the AWS Console to create and configure the resource manually.

### 1. Create an RDS Instance
1. Open **AWS Management Console → RDS**.  
2. Click **Create database**.  
3. Choose **Standard create**.  
4. Select **MySQL** as the database engine.  
5. Select **Engine version** as `MySQL 8.0.42`
5. Select **Free tier** to avoid charges.

### 2. Configure Database Settings
1. Set **DB instance identifier:** `my-demo-db`  
2. Set **Master username:** `admin`
3. Select **Credentials management** as **Self managed**  
3. Set **Master password:** Choose a strong password and **note it down** somewhere safe.

### 3. Configure Storage
1. **Storage type:** General Purpose (SSD)  
2. **Allocated storage:** 20 GiB  
3. Keep **storage auto-scaling enabled** under Additional storage configuration.

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

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)
<details> <summary>Run commands to create/configure the resource via CLI</summary> 

> Run these AWS CLI commands to quickly create and configure the resource without navigating the Console.

```bash
echo "Fetching Private Subnet IDs..."
PRIVATE_SUBNET_IDS=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=demo-app-private-subnet-1,demo-app-private-subnet-2,demo-app-private-subnet-3" \
    --query "Subnets[].SubnetId" --output text --no-cli-pager)

echo "Private Subnet IDs found: $PRIVATE_SUBNET_IDS"

# Assign them to variables (assuming 3 subnets)
PRIVATE_SUBNET_1=$(echo $PRIVATE_SUBNET_IDS | awk '{print $1}')
PRIVATE_SUBNET_2=$(echo $PRIVATE_SUBNET_IDS | awk '{print $2}')
PRIVATE_SUBNET_3=$(echo $PRIVATE_SUBNET_IDS | awk '{print $3}')

echo "✅ Using Subnets: $PRIVATE_SUBNET_1, $PRIVATE_SUBNET_2, $PRIVATE_SUBNET_3"

```

```bash

#!/bin/bash
    check_var() {
        VAR_NAME=$1
        if [ -z "${!VAR_NAME}" ]; then
            echo "⚠️  Environment variable $VAR_NAME is not set."
            echo "👉 Please set it using: export $VAR_NAME=<value>"
            echo "💡 Then rerun this block."
            read -rp "👉 Press Enter to exit the script safely..."
            return 1
        fi
    }

check_var "PRIVATE_SUBNET_1"
check_var "PRIVATE_SUBNET_2"
check_var "PRIVATE_SUBNET_3"

# Create a DB Subnet Group
echo "Creating DB Subnet Group: demo-app-db-subnet-group"
DB_SUBNET_GROUP_NAME="demo-app-db-subnet-group"
DB_SUBNET_GROUP=$(aws rds create-db-subnet-group \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
    --db-subnet-group-description "Demo App DB Subnet Group" \
    --subnet-ids $PRIVATE_SUBNET_1 $PRIVATE_SUBNET_2 $PRIVATE_SUBNET_3 \
    --tags Key=Name,Value=$DB_SUBNET_GROUP_NAME \
    --query "DBSubnetGroup.DBSubnetGroupName" --output text --no-cli-pager)

if [ "$DB_SUBNET_GROUP" == "$DB_SUBNET_GROUP_NAME" ]; then
    echo "✅ DB Subnet Group created: $DB_SUBNET_GROUP"
else
    echo "⚠️ Failed to create DB Subnet Group: $DB_SUBNET_GROUP_NAME"
fi
```

```bash

#!/bin/bash
    check_var() {
        VAR_NAME=$1
        if [ -z "${!VAR_NAME}" ]; then
            echo "⚠️  Environment variable $VAR_NAME is not set."
            echo "👉 Please set it using: export $VAR_NAME=<value>"
            echo "💡 Then rerun this block."
            read -rp "👉 Press Enter to exit the script safely..."
            return 1
        fi
    }

check_var "VPC_ID"

# Create Security Group for RDS
echo "Creating Security Group: demo-app-db-sg"
DB_SG_ID=$(aws ec2 create-security-group \
    --group-name demo-app-db-sg \
    --description "DB security group for RDS instance" \
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value=demo-app-db-sg}]' \
    --query "GroupId" --output text --no-cli-pager)

if [ -n "$DB_SG_ID" ] && [ "$DB_SG_ID" != "None" ]; then
    echo "✅ Security Group created: $DB_SG_ID"
else
    echo "⚠️ Failed to create Security Group demo-app-db-sg"
fi
```

✅ **Set a strong password for your RDS Instance and note it down safely.**

```bash
export RDS_PASSWORD="<set-a-strong-password>"
```

```bash
#!/bin/bash
    check_var() {
        VAR_NAME=$1
        if [ -z "${!VAR_NAME}" ]; then
            echo "⚠️  Environment variable $VAR_NAME is not set."
            echo "👉 Please set it using: export $VAR_NAME=<value>"
            echo "💡 Then rerun this block."
            read -rp "👉 Press Enter to exit the script safely..."
            return 1
        fi
    }

check_var "RDS_PASSWORD"
check_var "DB_SUBNET_GROUP_NAME"
check_var "DB_SG_ID"

# 3️⃣ Create RDS Instance
echo "Creating RDS Instance: my-demo-db"
DB_INSTANCE_ID=$(aws rds create-db-instance \
    --db-instance-identifier my-demo-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.42 \
    --allocated-storage 20 \
    --master-username admin \
    --master-user-password $RDS_PASSWORD \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
    --vpc-security-group-ids $DB_SG_ID \
    --no-publicly-accessible \
    --storage-type gp2 \
    --backup-retention-period 7 \
    --tags Key=Name,Value=my-demo-db \
    --query "DBInstance.DBInstanceIdentifier" --output text --no-cli-pager)

if [ "$DB_INSTANCE_ID" == "my-demo-db" ]; then
    echo "✅ RDS Instance creation started: $DB_INSTANCE_ID"
else
    echo "⚠️ Failed to create RDS Instance my-demo-db"
fi
```

```bash
# Wait until RDS is available
echo "Waiting for RDS Instance my-demo-db to become available..."
aws rds wait db-instance-available --db-instance-identifier my-demo-db --no-cli-pager

if [ $? -eq 0 ]; then
    echo "✅ RDS Instance my-demo-db is now available"
else
    echo "⚠️ Timeout or failure while waiting for RDS Instance my-demo-db"
fi

```
</details>

---

### ✅ Validation (Check if Resource Created Correctly)
<details> <summary>Validate the Resource</summary> 

> After creating resources (either via AWS Console or AWS CLI), validate them using the pre-built script.
> Run the following in CloudShell:

```bash
# Download the validation script from GitHub
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/resource-validation-scripts/2-validate-rds.sh

# Make it executable
chmod +x 2-validate-rds.sh

# Run the script
./2-validate-rds.sh

```

</details>

---

## Part 3: Set Up S3


### 📖 Theory
<details> <summary>Understanding the Resource</summary> 

> Understand why this resource is needed and how it fits into the AWS architecture before creating it.

In this step, we create an **Amazon S3 bucket** to store files uploaded by users.  

- The bucket will hold **images, documents, or any backend files** required by the application.  
- **Proper permissions and versioning** ensure security and easy recovery of files.  
- After this step, the S3 bucket is ready to support backend file storage.  
- Files uploaded to the `demo-app` will be stored here.  

---

#### Detailed Explanation

**Why a Separate Storage Layer?**  
In a **cloud-native architecture**, it’s best practice to separate **file storage** from your application’s **compute layer**.  
This ensures files are not tied to a single server and remain available even if servers are replaced, restarted, or scaled.  

**Amazon S3 (Simple Storage Service):**  
- Provides **object storage** that is **scalable, durable, and highly available**.  
- Allows storing and retrieving **any amount of data** at any time.  
- Removes the need to manage physical disks or worry about capacity planning.  

**Key Features for Security & Reliability:**  
- **Bucket Versioning:** Keeps multiple versions of a file → easy recovery from **accidental deletions or overwrites**.  
- **Block Public Access:** Prevents files from being exposed to the internet by default → critical for protecting **sensitive data**.  
- **IAM Policies & Permissions:** Ensure only authorized services (e.g., your app servers) can access the bucket.  

---

✅ **Why this matters:**  
By using S3 for file storage, you gain a **cost-effective, secure, and highly durable storage solution** that integrates seamlessly with the rest of your AWS architecture.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---
### 🖥️ AWS Console (Old School Way – Clicks & GUI)
<details> <summary>Create and Configure the Resource via AWS Console</summary> 

> Follow these steps in the AWS Console to create and configure the resource manually.

### 1. Create an S3 Bucket
1. Open **AWS Console → Navigate to S3**.
2. Click **Create bucket**.
3. Enter a unique bucket name, for example:  
   `demo-app-backend-s3-bucket-1234`  
   
   🚨 **Important:**  
   - S3 bucket names must be globally unique across all AWS accounts.  
   - You may use a different name if this one is not available.  
   - **Note:** Keep a record of this bucket name as it will be required later.  
   - It is recommended to add a random string at the end of the bucket name `demo-app-backend-s3-bucket-1234-<some-random-string>` to avoid conflicts or confusion.

4. Choose the **same region** as your VPC (e.g., `us-east-1`).
5. Keep **Block Public Access enabled** (recommended for security).
6. Disable **Bucket Versioning** (optional – useful to keep previous versions of uploaded files.)
7. Leave other settings as default and click **Create bucket**.
8. Click **Create bucket**.  


✅ Your S3 bucket is now ready to store backend files for the demo application.

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)
<details> <summary>Run commands to create/configure the resource via CLI</summary> 

> Run these AWS CLI commands to quickly create and configure the resource without navigating the Console.


✅ **Set a unique backend S3 bucket name. It is recommended to append a random string at the end of the bucket name, e.g., `demo-app-backend-s3-bucket-12345-<some-random-string>`, to avoid conflicts or confusion**


```bash
export BACKEND_BUCKET_NAME="demo-app-backend-s3-bucket-12345"
```

```bash

#!/bin/bash
    check_var() {
        VAR_NAME=$1
        if [ -z "${!VAR_NAME}" ]; then
            echo "⚠️  Environment variable $VAR_NAME is not set."
            echo "👉 Please set it using: export $VAR_NAME=<value>"
            echo "💡 Then rerun this block."
            read -rp "👉 Press Enter to exit the script safely..."
            return 1
        fi
    }

check_var "BACKEND_BUCKET_NAME"

BACKEND_BUCKET_NAME=$BACKEND_BUCKET_NAME
REGION="us-east-1"

echo "Creating S3 Bucket: $BACKEND_BUCKET_NAME in $REGION"

if [ "$REGION" == "us-east-1" ]; then
    # us-east-1 special case
    aws s3api create-bucket \
        --bucket $BACKEND_BUCKET_NAME \
        --region $REGION \
        --no-cli-pager >/dev/null 2>&1
else
    # all other regions need LocationConstraint
    aws s3api create-bucket \
        --bucket $BACKEND_BUCKET_NAME \
        --region $REGION \
        --create-bucket-configuration LocationConstraint=$REGION \
        --no-cli-pager >/dev/null 2>&1
fi

# Verify bucket creation
if aws s3api head-bucket --bucket $BACKEND_BUCKET_NAME 2>/dev/null; then
    echo "✅ S3 Bucket created: $BACKEND_BUCKET_NAME"
else
    echo "⚠️ Failed to create S3 Bucket: $BACKEND_BUCKET_NAME"
fi

```

</details>

---

### ✅ Validation (Check if Resource Created Correctly)
<details> <summary>Validate the Resource</summary> 

> After creating resources (either via AWS Console or AWS CLI), validate them using the pre-built script.
> Run the following in CloudShell:

✅ **Set your backend S3 bucket name exactly as you used when creating the backend bucket. Ensure it matches the name in AWS to avoid any mismatches, e.g., `demo-app-backend-s3-bucket-12345-<some-random-string>`**

```bash
export BACKEND_BUCKET_NAME="demo-app-backend-s3-bucket-12345"
```

```bash
# Download the validation script from GitHub
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/resource-validation-scripts/3-validate-s3.sh

# Make it executable
chmod +x 3-validate-s3.sh

# Run the script
./3-validate-s3.sh

```

</details>

---


## Part 4: Configure SNS to Send Email Notifications on S3 File Uploads


### 📖 Theory
<details> <summary>Understanding the Resource</summary> 

> Understand why this resource is needed and how it fits into the AWS architecture before creating it.

In this step, we use **Amazon SNS (Simple Notification Service)** to get email alerts whenever a file is uploaded to **S3**.  

- An **SNS topic** is created and linked to the S3 bucket.  
- Users can **subscribe via email** to receive real-time notifications.  
- This ensures the team is immediately aware of **new uploads** for processing or auditing.  

---

#### Detailed Explanation

**Why Decoupling Matters?**  
A key principle of building **scalable architectures** is to **decouple services**.  
Instead of one service directly calling another, we use **event-driven messaging**. This improves flexibility, reliability, and scalability.  

**Amazon SNS (Simple Notification Service):**  
- A **fully managed pub/sub (publish/subscribe)** messaging service.  
- **Publisher:** A service that generates events (here, the S3 bucket).  
- **Subscribers:** Services or endpoints that receive the event (here, an email endpoint, and later possibly Lambda).  

**How it works in our setup:**  
1. A file is uploaded to the **S3 bucket** (event trigger).  
2. S3 publishes a **notification** to the SNS topic.  
3. SNS **broadcasts the message** to all its subscribers.  
   - Example: Email notification to the team.  
   - Example (future): A Lambda function to process the file.  

**Benefits of SNS Integration:**  
- **Loose Coupling:** Services don’t depend directly on each other.  
- **Scalability:** Easily add new subscribers (e.g., another app, SMS, or Lambda) without modifying S3.  
- **Flexibility:** Supports multiple use cases like file processing, auditing, or triggering workflows.  

---

✅ **Why this matters:**  
By introducing SNS, we’re moving towards an **event-driven, decoupled architecture** that makes our system more **resilient, extensible, and scalable** for future enhancements.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 🖥️ AWS Console (Old School Way – Clicks & GUI)
<details> <summary>Create and Configure the Resource via AWS Console</summary> 

> Follow these steps in the AWS Console to create and configure the resource manually.


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

> **Note:** You should see the status as **Confirmed** for your subscription


### 3. Update SNS Topic Policy to Allow S3 to Publish
1. In SNS Console, click `demo-app-sns-topic`.
2. Click **Edit → Access policy**.
3. Replace the existing policy with:

> **Note:** In the following policy, replace `YOUR_AWS_ACCOUNT_ID` with your AWS Account ID.

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

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)
<details> <summary>Run commands to create/configure the resource via CLI</summary> 

> Run these AWS CLI commands to quickly create and configure the resource without navigating the Console.


```bash
SNS_TOPIC_NAME="demo-app-sns-topic"
S3_BUCKET_NAME="demo-app-backend-s3-bucket-12345"
EVENT_NAME="demo-app-s3-object-upload-notification"

#Create SNS Topic
echo "Creating SNS Topic: $SNS_TOPIC_NAME"

SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)

if [ "$SNS_TOPIC_ARN" != "None" ] && [ -n "$SNS_TOPIC_ARN" ]; then
    echo "⚠️ SNS Topic already exists: $SNS_TOPIC_ARN"
else
    SNS_TOPIC_ARN=$(aws sns create-topic --name $SNS_TOPIC_NAME --query 'TopicArn' --output text)
    echo "✅ SNS Topic created: $SNS_TOPIC_ARN"
fi

# Subscribe Email to SNS Topic
EMAIL="your-email@example.com"
echo "Subscribing email $EMAIL to SNS Topic $SNS_TOPIC_NAME"

SUBSCRIPTION_ARN=$(aws sns list-subscriptions-by-topic --topic-arn $SNS_TOPIC_ARN --query "Subscriptions[?Endpoint=='$EMAIL'].SubscriptionArn" --output text)

if [ "$SUBSCRIPTION_ARN" != "None" ] && [ -n "$SUBSCRIPTION_ARN" ]; then
    echo "⚠️ Email already subscribed: $EMAIL"
else
    aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol email --notification-endpoint $EMAIL
    echo "✅ Subscription request sent. Confirm the subscription from your email: $EMAIL"
fi

# Update SNS Topic Policy to Allow S3 to Publish
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
echo "Updating SNS Topic Policy to allow S3 to publish"

SNS_POLICY=$(cat <<EOF
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
      "Resource": "$SNS_TOPIC_ARN",
      "Condition": {
        "StringEquals": {
          "aws:SourceAccount": "$AWS_ACCOUNT_ID"
        }
      }
    }
  ]
}
EOF
)

aws sns set-topic-attributes --topic-arn $SNS_TOPIC_ARN --attribute-name Policy --attribute-value "$SNS_POLICY"
echo "✅ SNS Topic policy updated to allow S3 to publish"

# Configure S3 Bucket Event Notification to Trigger SNS

echo "Configuring S3 Bucket $S3_BUCKET_NAME to trigger SNS Topic on object create"

aws s3api put-bucket-notification-configuration \
    --bucket $S3_BUCKET_NAME \
    --notification-configuration "{
        \"TopicConfigurations\": [
            {
                \"Id\": \"$EVENT_NAME\",
                \"TopicArn\": \"$SNS_TOPIC_ARN\",
                \"Events\": [\"s3:ObjectCreated:*\"] 
            }
        ]
    }"
echo "✅ S3 bucket configured to send SNS notifications on object upload"

```

</details>

---

### ✅ Validation (Check if Resource Created Correctly)
<details> <summary>Validate the Resource</summary> 

> After creating resources (either via AWS Console or AWS CLI), validate them using the pre-built script.
> Run the following in CloudShell:

```bash
# Download the validation script from GitHub
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/resource-validation-scripts/4-validate-sns.sh

# Make it executable
chmod +x 4-validate-sns.sh

# Run the script
./4-validate-sns.sh

```

</details>

---

## Part 5: Create DynamoDB Table and Lambda for File Metadata Extraction & Storage

### 📖 Theory
<details> <summary>Understanding the Resource</summary> 

> Understand why this resource is needed and how it fits into the AWS architecture before creating it.

In this step, we **store metadata of uploaded files in DynamoDB using a Lambda function**:  

- A **DynamoDB table** is created to save details like `file_name`, `bucket_name`, and `upload_timestamp`.  
- **Lambda** is triggered by the **SNS notification** from S3 uploads.  
- This automates **tracking and management** of uploaded files, enabling easy retrieval and further processing.  

---

#### Detailed Explanation

**AWS Lambda (Serverless Compute):**  
- A **serverless, event-driven compute service**.  
- No servers to provision or manage.  
- Runs your code automatically in response to events.  
- In our case, the event is an **SNS message** triggered when a file is uploaded to S3.  
- Lambda acts as the **glue** between the storage (S3) and data (DynamoDB) layers.  

**Amazon DynamoDB (NoSQL Database):**  
- A **fully managed NoSQL database** designed for **key-value** and **document** data.  
- Extremely **fast, scalable, and schema-less** (no fixed schema required).  
- Perfect for storing **lightweight, structured metadata** such as:  
  - `file_name`  
  - `bucket_name`  
  - `upload_timestamp`  

**Workflow in Our Setup:**  
1. A file is uploaded to **S3**.  
2. S3 triggers an **SNS notification**.  
3. The **SNS topic** invokes the **Lambda function**.  
4. Lambda extracts **file metadata** and stores it in **DynamoDB**.  

**Benefits of This Design:**  
- **Fully automated:** No manual intervention needed for tracking uploads.  
- **Serverless:** Scales automatically, no server management required.  
- **Event-driven:** Each upload triggers the workflow instantly.  
- **Seamless integration:** Storage, processing, and data management work together.  

---

✅ **Why this matters:**  
This pipeline (S3 → SNS → Lambda → DynamoDB) is a **classic serverless, event-driven architecture**. It’s **scalable, cost-efficient, and maintenance-free**, making it ideal for modern cloud-native applications.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 🖥️ AWS Console (Old School Way – Clicks & GUI)
<details> <summary>Create and Configure the Resource via AWS Console</summary> 

> Follow these steps in the AWS Console to create and configure the resource manually.

### 1. Create a DynamoDB Table
1. Go to AWS Console → DynamoDB → Tables → **Create Table**.
2. Enter **Table name:** `demo-app-file-metadata-dynamodb`.
3. Set **Partition Key:**  
   - Name: `file_name`  
   - Type: String
4. Leave all other settings as default.
5. Click **Create Table**.

> **Important:** You don’t need to manually define other required attributes like `upload_time` or `file_size`. These will be dynamically inserted by the Lambda function. You can view them under **Explore Items** in DynamoDB later.

---

### 2. Create an IAM Role for Lambda
1. Go to **IAM Console → Roles → Create role**.
2. Select **AWS Service → Lambda → Next**.
3. Search and attach the following policies:
   - `AmazonS3ReadOnlyAccess` (To read files from S3)  
   - `AmazonDynamoDBFullAccess` (To write metadata to DynamoDB)  
   - `AWSLambdaBasicExecutionRole` (For CloudWatch logging)
4. Click on Next.
5. Name the role: `demo-app-lambda-iam-role`.
6. Create the role and note the **Role ARN**.

----


### 3. Create a Lambda Function
1. Go to **Lambda Console → Create function**.
2. Choose **Author from scratch**.
3. Enter **Function Name:** `demo-app-metadata-lambda`.
4. Select **Python 3.13** as Runtime.
5. Choose **Use an existing role** and select the IAM role created earlier (`demo-app-lambda-iam-role`) under **Change default execution role**.
6. Click **Create Function**.

---

### 4. Subscribe Lambda to Existing SNS Topic
1. Go to **SNS Console → Your SNS Topic (`demo-app-sns-topic`)**.
2. Click **Create Subscription**.
3. Protocol: **AWS Lambda**.
4. Select the Lambda Function you created (`demo-app-metadata-lambda`).
5. Click **Create Subscription**.
6. Return to the SNS Topic `demo-app-sns-topic` and verify that there are now **2 subscriptions**, both showing the **Status: Subscribed**.

---

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
   - You should see a log entry like:  
     `Extracted File: <your file name> from Bucket: <your bucket name>`
5. Go to **DynamoDB → Explore Items**, select the table `demo-app-file-metadata-dynamodb`, and click **Run**.
   - You should see **one entry** corresponding to the file you just uploaded.

✅ This confirms that uploading a file to S3 triggers SNS, which sends an email, invokes Lambda, and writes metadata to DynamoDB successfully.

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)
<details> <summary>Run commands to create/configure the resource via CLI</summary> 

> Run these AWS CLI commands to quickly create and configure the resource without navigating the Console.

### 1. Create a DynamoDB Table

```bash
# Create DynamoDB Table
echo "Creating DynamoDB Table: demo-app-file-metadata-dynamodb"
DDB_TABLE=$(aws dynamodb describe-table \
    --table-name demo-app-file-metadata-dynamodb \
    --query "Table.TableName" --output text 2>/dev/null)

if [ "$DDB_TABLE" == "demo-app-file-metadata-dynamodb" ]; then
    echo "⚠️ DynamoDB Table already exists: $DDB_TABLE"
else
    aws dynamodb create-table \
        --table-name demo-app-file-metadata-dynamodb \
        --attribute-definitions AttributeName=file_name,AttributeType=S \
        --key-schema AttributeName=file_name,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --tags Key=Name,Value=demo-app-file-metadata-dynamodb \
        --no-cli-pager
    echo "✅ DynamoDB Table created: demo-app-file-metadata-dynamodb"
fi
```

---

### 2. Create an IAM Role for Lambda

```bash
#Create IAM Role for Lambda
echo "Creating IAM Role: demo-app-lambda-iam-role"
ROLE_ARN=$(aws iam get-role --role-name demo-app-lambda-iam-role --query 'Role.Arn' --output text 2>/dev/null)

if [ -n "$ROLE_ARN" ]; then
    echo "⚠️ IAM Role already exists: $ROLE_ARN"
else
    TRUST_POLICY='{
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Principal": { "Service": "lambda.amazonaws.com" },
        "Action": "sts:AssumeRole"
      }]
    }'
    ROLE_ARN=$(aws iam create-role \
        --role-name demo-app-lambda-iam-role \
        --assume-role-policy-document "$TRUST_POLICY" \
        --query 'Role.Arn' --output text)
    echo "✅ IAM Role created: $ROLE_ARN"

    # Attach policies
    aws iam attach-role-policy --role-name demo-app-lambda-iam-role --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
    aws iam attach-role-policy --role-name demo-app-lambda-iam-role --policy-arn arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess
    aws iam attach-role-policy --role-name demo-app-lambda-iam-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    echo "✅ Attached S3, DynamoDB & Lambda basic execution policies"
fi
```

---

### 3. Create a Lambda Function with Code

```bash
# Create Lambda Function
echo "Creating Lambda Function: demo-app-metadata-lambda"
LAMBDA_ARN=$(aws lambda get-function --function-name demo-app-metadata-lambda --query 'Configuration.FunctionArn' --output text 2>/dev/null)

if [ -n "$LAMBDA_ARN" ]; then
    echo "⚠️ Lambda function already exists: $LAMBDA_ARN"
else
   # Create a minimal empty Lambda zip
   echo "Downloading Lambda code from GitHub..."
   curl -L -o lambda_function.py https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/backend/demo-app-metadata-lambda
   zip lambda_function.zip lambda_function.py >/dev/null 2>&1

   # Create Lambda function
   aws lambda create-function \
      --function-name demo-app-metadata-lambda \
      --runtime python3.13 \
      --role "$ROLE_ARN" \
      --handler lambda_function.lambda_handler \
      --zip-file fileb://lambda_function.zip \
      --timeout 30 \
      --memory-size 128 \
      --tags Name=demo-app-metadata-lambda \
      --no-cli-pager

   echo "✅ Lambda function created: demo-app-metadata-lambda"
fi
```

---

### 4. Subscribe Lambda to Existing SNS Topic

```bash

# Fetch Lambda ARN
LAMBDA_ARN=$(aws lambda get-function \
    --function-name demo-app-metadata-lambda \
    --query 'Configuration.FunctionArn' --output text --no-cli-pager)

if [ -z "$LAMBDA_ARN" ] || [ "$LAMBDA_ARN" == "None" ]; then
    echo "❌ Lambda function not found. Create it first."
    exit 1
else
    echo "✅ Lambda ARN: $LAMBDA_ARN"
fi

# Fetch SNS Topic ARN
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn,'demo-app-sns-topic')].TopicArn | [0]" --output text)

if [ -z "$SNS_TOPIC_ARN" ] || [ "$SNS_TOPIC_ARN" == "None" ]; then
    echo "❌ SNS Topic demo-app-sns-topic not found. Create the SNS Topic first."
    exit 1
else
    echo "✅ SNS Topic ARN: $SNS_TOPIC_ARN"
fi

# Subscribe Lambda to SNS Topic
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn,'demo-app-sns-topic')].TopicArn | [0]" --output text)

if [ -z "$SNS_TOPIC_ARN" ] || [ "$SNS_TOPIC_ARN" == "None" ]; then
    echo "❌ SNS Topic demo-app-sns-topic not found. Create the SNS Topic first."
else
    SUBSCRIPTION_ARN=$(aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPIC_ARN" \
        --query "Subscriptions[?Endpoint=='$LAMBDA_ARN'].SubscriptionArn" --output text)

    if [ -n "$SUBSCRIPTION_ARN" ]; then
        echo "⚠️ Lambda already subscribed to SNS Topic: $SUBSCRIPTION_ARN"
    else
        aws sns subscribe \
            --topic-arn "$SNS_TOPIC_ARN" \
            --protocol lambda \
            --notification-endpoint "$LAMBDA_ARN" \
            --no-cli-pager
        echo "✅ Lambda subscribed to SNS Topic: $SNS_TOPIC_ARN"
    fi
fi

# Ensure Lambda has permission to be invoked by SNS
STATEMENT_ID="sns-invoke-demo-app"
PERMISSION_EXISTS=$(aws lambda get-policy --function-name demo-app-metadata-lambda --query "Policy" --output text 2>/dev/null | grep "$STATEMENT_ID" || true)

if [ -n "$PERMISSION_EXISTS" ]; then
    echo "⚠️ Lambda already has permission for SNS to invoke"
else
    aws lambda add-permission \
        --function-name demo-app-metadata-lambda \
        --statement-id "$STATEMENT_ID" \
        --action lambda:InvokeFunction \
        --principal sns.amazonaws.com \
        --source-arn "$SNS_TOPIC_ARN" \
        --no-cli-pager
    echo "✅ Added permission for SNS to invoke Lambda"
fi
```

</details>

---

### ✅ Validation (Check if Resource Created Correctly)
<details> <summary>Validate the Resource</summary> 

> After creating resources (either via AWS Console or AWS CLI), validate them using the pre-built script.
> Run the following in CloudShell:

```bash
# Download the validation script from GitHub
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/resource-validation-scripts/5-validate-dynamodb-lambda.sh

# Make it executable
chmod +x 5-validate-dynamodb-lambda.sh

# Run the script
./5-validate-dynamodb-lambda.sh

```

</details>

---

## Part 6: Deploy a Flask Application on Test AMI Builder EC2 with RDS & S3, DynamoDB Integration in Public Subnet

### 📖 Theory
<details> <summary>Understanding the Resource</summary> 

> Understand why this resource is needed and how it fits into the AWS architecture before creating it.

In this step, we **deploy the backend Flask application** on a test **EC2 instance** with full integration to **RDS, S3, and DynamoDB**.  

---

#### Detailed Explanation

**Application Layer (Business Logic):**  
- This is the **core of the three-tier architecture** where your **business logic** resides.  
- We use **Amazon EC2 (Elastic Compute Cloud)** as the application server.  
- Think of EC2 as a **virtual machine in the cloud**, giving you full control over OS, software, and environment.  
- The EC2 instance is launched in a **public subnet** so it’s easily accessible for testing.  

**IAM Role for Secure Access:**  
- Instead of storing AWS keys inside your code, we attach an **IAM Role** to the EC2 instance.  
- The IAM Role grants the Flask app the necessary permissions to:  
  - Read/write files in **S3**.  
  - Insert/retrieve metadata from **DynamoDB**.  
- This is a **best practice for security**, since no credentials are hardcoded in the app.  

**Flask Application (Integration Hub):**  
- Acts as the **communication hub** between the frontend and backend services.  
- Handles requests and routes them to the correct services.  
- Uses:  
  - **pymysql** → To connect to **RDS MySQL** (data layer) for CRUD operations.  
  - **boto3** → To interact with:  
    - **S3** for file uploads/downloads.  
    - **DynamoDB** for retrieving file metadata.  

**Service Management (systemd):**  
- We configure the Flask app as a **systemd service**.  
- This ensures:  
  - The app **starts automatically** on EC2 reboot.  
  - The app stays **running reliably** in the background.  

---

✅ **Why this matters:**  
The **application layer** is the glue that ties everything together — frontend, database, file storage, and metadata. By combining **EC2, IAM roles, Flask, and AWS SDKs**, we build a secure, modular, and production-ready backend for the three-tier architecture.  

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 🖥️ AWS Console (Old School Way – Clicks & GUI)
<details> <summary>Create and Configure the Resource via AWS Console</summary> 

> Follow these steps in the AWS Console to create and configure the resource manually.

### 1. Create an IAM Role for S3 and DynamoDB Access
1. Open AWS IAM Console → **Roles → Create Role**.
2. Select **AWS Service → EC2 → Next**.
3. Search and attach the following policies:  
   - `AmazonS3FullAccess`  
   - `AmazonDynamoDBReadOnlyAccess`
4. Click on Next.   
5. Name the role: `demo-app-s3-dynamo-iam-role`
6. Click **Create**.

### 2. Launch a Test and AMI Builder EC2 Instance
1. Open AWS EC2 Console → **Launch Instance**.
2. Enter **Instance Name:** `demo-app-test-ami-builder`.
3. Choose AMI: Ubuntu Server 24.04 LTS (HVM), SSD Volume Type .
4. Instance Type: `t2.micro` (free-tier) or as required.
5. Key Pair: Create or select an existing key pair (download `.pem` for terminal(Linux/Mac), `.ppk` for Putty(Windows)).  
   Name: `demo-app-private-key`.
6. Network → Edit : Select your `demo-app-vpc` VPC → Subnet: `demo-app-public-subnet-1`.
7. Enable `Auto-assign Public IP`.
8. Security Group: Create or select:  
   - Name: `demo-app-test-ami-builder-sg`  
   - Allow SSH (22) from Anywhere (Not recommended in Production, ok for Testing)
   - Allow 5000 from Anywhere
9. Under **Advanced details** → **IAM instance profile** Attach IAM role: `demo-app-s3-dynamo-iam-role`.
10. Launch the instance and copy the **Public IP**.

### ⚠️ Note

Make sure **Auto-assign Public IP** is enabled; otherwise, you won’t be able to access the instance from the internet unless you manually associate an Elastic IP.

### 3. Connect to the Test AMI Builder

1. Go to the EC2 instance you just launched.
2. Under the **Details** section, find the **Public IPv4 address** and copy it.  
   - This is the IP you will use to connect to the instance.
3. Based on your workstation OS, choose one of the following:

**For macOS/Linux (Terminal):**  
```bash
# Set the correct permissions for your private key
chmod 400 /path/to/your/key/demo-app-private-key.pem

# Connect to your EC2 instance
ssh -i /path/to/your/key/demo-app-private-key.pem ubuntu@<EC2_PUBLIC_IP>
````

**For Windows (Putty):**

1. Open **Putty**, enter the **Public IPv4 address** in the Host Name field.
2. Under **SSH → Auth**, browse and select your `.ppk` key file.
3. Click **Open** to connect.
4. Enter Ubuntu username

> ⚠️ **Note:** If SSH or port 22 is not working even after all correct configurations, you can temporarily allow SSH (port 22) from **all IPs (0.0.0.0/0)** in your security group to troubleshoot. Remember to tighten it later for security.

✅ Once connected, your instance is ready for **package installation, application deployment, testing, and AMI creation**.

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
RDS_HOST = "CHANGE_ME_RDS_HOST"
RDS_USER = "CHANGE_ME_RDS_USER"
RDS_PASSWORD = "CHANGE_ME_RDS_PASSWORD"
RDS_DATABASE = "demo"
S3_BUCKET = "CHANGE_ME_BACKEND_S3_BUCKET"
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

# --------------------
# Health Check
# --------------------
@app.route("/", methods=["GET"])
def healthcheck():
    return jsonify({"status": "ok", "message": "Service is healthy"}), 200

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

1. Open **AWS Console → Navigate to S3**.
2. Click **Create bucket**.
3. Enter a unique bucket name, for example:  
   `demo-app-frontend-s3-bucket-6789`  
   
   🚨 **Important:**  
   - S3 bucket names must be globally unique across all AWS accounts.  
   - You may use a different name if this one is not available.  
   - **Note:** Keep a record of this bucket name as it will be required later.  
   - It is recommended to add a random string at the end of the bucket name `demo-app-frontend-s3-bucket-6789-<some-random-string>` to avoid conflicts or confusion.

4. Choose the **same region** as your VPC (e.g., `us-east-1`).
5. Disable **Block public access**. Tick the checkbox `I acknowledge that the current settings might result in this bucket and the objects within becoming public.`
6. Disable **Bucket Versioning** (optional – useful to keep previous versions of uploaded files.)
7. Leave other settings as default and click **Create bucket**.
8. Click **Create bucket**.  
9. Go to the Bucket → Properties → Static website hosting → Edit → Enable **Static website hosting** → Index document: `index.html`.
4. Go to the Bucket → Permissions → Edit **Bucket Policy**: and paste the following. Change Resource ARN to match with you bucket name → Save changes

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

5. **Download the `index.html` file** from the repo:
   [Frontend `index.html`](https://github.com/shivalkarrahul/demo-three-tier-app-on-aws/blob/main/frontend/index.html)

6. **Edit the file** to update the backend API endpoint:

   * Open `index.html` in a text editor.
   * Find the line with:

     ```javascript
     const API_BASE = "http://<EC2IP>:5000";
     ```
   * Replace `<EC2IP>` with your EC2 Public IP and keep the port unchanged, for example:

     ```javascript
     const API_BASE = "http://192.199.100.111:5000";
     ```

7. **Save the file** after updating the API endpoint.

8. **Upload the updated `index.html`** to your frontend hosting S3 Bucket (`demo-app-frontend-s3-bucket-6789`):

   * Go to your frontend S3 bucket → Upload → Select `index.html` → Upload.


### 7. Start the Flask Application

1. **SSH into your EC2 instance** (Test AMI Builder) if not already connected.
2. **Navigate to the Flask application directory** and set up the environment:

```bash
cd /home/ubuntu/flask-app
source /home/ubuntu/venv/bin/activate   # Activate virtual environment
```

3. **Start the Flask application**:

```bash
python3 app.py
```

4. **Expected logs** when the Flask app fails to start:

```
Traceback (most recent call last):
  File "/home/ubuntu/flask-app/venv/lib/python3.12/site-packages/pymysql/connections.py", line 661, in connect
    sock = socket.create_connection(
           ^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/usr/lib/python3.12/socket.py", line 852, in create_connection
    raise exceptions[0]
  File "/usr/lib/python3.12/socket.py", line 837, in create_connection
    sock.connect(sa)
TimeoutError: timed out

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "/home/ubuntu/flask-app/app.py", line 90, in <module>
    initialize_database()
  File "/home/ubuntu/flask-app/app.py", line 22, in initialize_database
    conn = pymysql.connect(host=RDS_HOST, user=RDS_USER, password=RDS_PASSWORD)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/ubuntu/flask-app/venv/lib/python3.12/site-packages/pymysql/connections.py", line 365, in __init__
    self.connect()
  File "/home/ubuntu/flask-app/venv/lib/python3.12/site-packages/pymysql/connections.py", line 723, in connect
    raise exc
pymysql.err.OperationalError: (2003, "Can't connect to MySQL server on 'my-demo-db.c66qvyoujzwv.us-east-1.rds.amazonaws.com' (timed out)")
```

> ⚠️ The connection to RDS fails, it is likely due to security group rules.
> To resolve this:
>
> * Go to **EC2** → **Security Groups** → search the `demo-app-db-sg` security group.
> * **Inbound rule** → **Edit inbound rule** → **Add rule** → Port range `3306` from the `demo-app-test-ami-builder-sg` security group → Save rule.
> * After updating the rules, retry starting the Flask application.

```bash
python3 app.py
```

5. **Expected logs** when the Flask app starts successfully:

```
(venv) ubuntu@ip-10-0-1-100:~/flask-app$ python3 app.py
 * Serving Flask app 'app'
 * Debug mode: on
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:5000
 * Running on http://10.0.1.100:5000
Press CTRL+C to quit
 * Restarting with stat
 * Debugger is active!
 * Debugger PIN: 805-847-091
```

5. **Test the frontend**:
   * Go to your frontend S3 bucket (e.g., `demo-app-frontend-s3-bucket-6789`) → Properties → Copy the Bucket website endpoint URL.
   
   * Open this S3 website URL in your browser.

   * The frontend should now communicate with your Flask backend running on EC2.

> ✅ Now your frontend is connected to your backend services and ready for interaction.


And You should be able to:

* **Insert User** in RDS
* **Fetch Users** from RDS
* **Upload File** to S3
* **List Files** in S3
* **Fetch File Metadata** from DynamoDB

After successfully deploying the frontend to S3 and accessing the S3 bucket website endpoint, you should see the application UI

![App UI ](artifacts/app-ui-s3.png)

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
```

5. Connect back to the instance and start the application
```bash
sudo systemctl status flask-app
```

✅ Your Flask app is now running as a **persistent, auto-starting systemd service**, integrated with **RDS, S3, and DynamoDB**, and connected to the frontend hosted on S3.

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)
<details> <summary>Run commands to create/configure the resource via CLI</summary> 

> Run these AWS CLI commands to quickly create and configure the resource without navigating the Console.


```bash
# Create IAM Role for EC2 with S3 + DynamoDB Access
echo "Creating IAM Role: demo-app-s3-dynamo-iam-role"

# Check if role already exists
ROLE_NAME="demo-app-s3-dynamo-iam-role"
ROLE_EXISTS=$(aws iam get-role --role-name $ROLE_NAME --query "Role.RoleName" --output text 2>/dev/null)

if [ "$ROLE_EXISTS" == "$ROLE_NAME" ]; then
    echo "⚠️ IAM Role already exists: $ROLE_NAME"
else
    # Create Trust Policy for EC2
    TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

    # Create the role
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document "$TRUST_POLICY" \
        --tags Key=Name,Value=$ROLE_NAME \
        --no-cli-pager

    echo "✅ IAM Role created: $ROLE_NAME"

    # Attach required policies
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:policy/AmazonS3FullAccess
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn arn:aws:policy/AmazonDynamoDBReadOnlyAccess
    echo "✅ Policies attached: AmazonS3FullAccess, AmazonDynamoDBReadOnlyAccess"
fi
```

```bash
#!/bin/bash

INSTANCE_NAME="demo-app-test-ami-builder"
KEY_NAME="demo-app-private-key"
SG_NAME="demo-app-test-ami-builder-sg"
ROLE_NAME="demo-app-s3-dynamo-iam-role"
AMI_ID="ami-0360c520857e3138f"

# 1. Create Key Pair if not exists
echo "🔑 Checking Key Pair: $KEY_NAME"
if aws ec2 describe-key-pairs --key-names $KEY_NAME --query "KeyPairs[*].KeyName" --output text 2>/dev/null | grep -q $KEY_NAME; then
    echo "⚠️ Key Pair already exists: $KEY_NAME"
else
    aws ec2 create-key-pair --key-name $KEY_NAME \
        --query "KeyMaterial" --output text > $KEY_NAME.pem
    chmod 400 $KEY_NAME.pem
    echo "✅ Key Pair created and saved: $KEY_NAME.pem"
fi

# 2. Get VPC and Subnet IDs
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=demo-app-vpc" --query "Vpcs[0].VpcId" --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=demo-app-public-subnet-1" --query "Subnets[0].SubnetId" --output text)

if [ "$VPC_ID" == "None" ] || [ "$SUBNET_ID" == "None" ]; then
    echo "❌ VPC or Subnet not found. Make sure demo-app-vpc and demo-app-public-subnet-1 exist."
    exit 1
fi

# 3. Create Security Group if not exists
echo "🛡️ Checking Security Group: $SG_NAME"
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$SG_NAME" "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

if [ "$SG_ID" == "None" ]; then
    SG_ID=$(aws ec2 create-security-group --group-name $SG_NAME \
        --description "Security Group for Test/Ami Builder Instance" \
        --vpc-id $VPC_ID --query "GroupId" --output text)
    echo "✅ Security Group created: $SG_NAME ($SG_ID)"

    # Add Inbound Rules
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 5000 --cidr 0.0.0.0/0
    echo "✅ Inbound rules added: SSH(22), App(5000)"
else
    echo "⚠️ Security Group already exists: $SG_NAME ($SG_ID)"
fi

# 4. Get IAM Instance Profile ARN
PROFILE_ARN=$(aws iam get-instance-profile --instance-profile-name $ROLE_NAME --query "InstanceProfile.Arn" --output text 2>/dev/null)
if [ -z "$PROFILE_ARN" ] || [ "$PROFILE_ARN" == "None" ]; then
    echo "❌ IAM Instance Profile not found. Make sure role $ROLE_NAME is created and added to instance profile."
    exit 1
fi

# 5. Launch EC2 Instance

echo "🚀 Launching EC2 Instance: $INSTANCE_NAME"
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --subnet-id $SUBNET_ID \
    --associate-public-ip-address \
    --security-group-ids $SG_ID \
    --iam-instance-profile Name=$ROLE_NAME \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" \
    --query "Instances[0].InstanceId" --output text)

echo "⏳ Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

# 6. Get Public IP
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
    --query "Reservations[0].Instances[0].PublicIpAddress" --output text)

echo "✅ EC2 Instance launched: $INSTANCE_NAME ($INSTANCE_ID)"
echo "🌍 Public IP: $PUBLIC_IP"
echo "🔑 Connect: ssh -i $KEY_NAME.pem ubuntu@$PUBLIC_IP"

# Make sure key permissions are correct
chmod 400 $KEY_NAME.pem

# Wait a bit for EC2 to finish initializing
echo "⏳ Waiting for EC2 SSH to be ready..."
sleep 30

# Install dependencies via SSH
ssh -o StrictHostKeyChecking=no -i $KEY_NAME.pem ubuntu@$PUBLIC_IP << 'EOF'
sudo apt update && sudo apt upgrade -y
sudo apt install -y python3 python3-pip python3-venv git vim

# Set up Python virtual environment
cd /home/ubuntu
python3 -m venv venv
source venv/bin/activate

# Install Python packages
pip install flask pymysql boto3 flask-cors
EOF

echo "✅ Dependencies installed on EC2 instance: $PUBLIC_IP"
```

```bash
export RDS_HOST="<YOUR-my-demo-db.ENDPOINT"
```

```bash
export RDS_USER="admin"
```

```bash
export RDS_PASSWORD="<YOUR-my-demo-db.PASSWORD>"
```

```bash
export S3_BACKEND_BUCKET="demo-app-backend-s3-bucket-12345"
```

```bash
export EC2_PUBLIC_IP="<YOU-demo-app-test-ami-builder-EC2-INSTANCE-PUBLIC-IP>"
```

```bash
export KEY_NAME="demo-app-private-key"
```

```bash
export S3_FRONTEND_BUCKET="demo-app-backend-s3-bucket-12345"
```

```bash
#!/bin/bash

# Ensure environment variables are set
: "${RDS_HOST:?Please export RDS_HOST before running the script}"
: "${RDS_USER:?Please export RDS_USER before running the script}"
: "${RDS_PASSWORD:?Please export RDS_PASSWORD before running the script}"
: "${S3_BACKEND_BUCKET:?Please export S3_BACKEND_BUCKET before running the script}"
: "${EC2_PUBLIC_IP:?Please export EC2_PUBLIC_IP before running the script}"
: "${KEY_NAME:?Please export KEY_NAME before running the script}"  # without .pem

# 2. Download app.py from GitHub
if rm -f app.py 2>/dev/null; then
    echo "🗑️ Removed existing app.py"
else
    echo "ℹ️ No existing app.py found, continuing..."
fi
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/backend/app.py

# 3. Replace placeholders in app.py
sed -i "s/CHANGE_ME_RDS_HOST/${RDS_HOST}/g" app.py
sed -i "s/CHANGE_ME_RDS_USER/${RDS_USER}/g" app.py
sed -i "s/CHANGE_ME_RDS_PASSWORD/${RDS_PASSWORD}/g" app.py
sed -i "s/CHANGE_ME_BACKEND_S3_BUCKET/${S3_BACKEND_BUCKET}/g" app.py

# 4. Copy app.py to the EC2 instance
ssh -i "$KEY_NAME.pem" -o StrictHostKeyChecking=no ubuntu@$EC2_PUBLIC_IP "mkdir -p /home/ubuntu/flask-app"
```

```bash
scp -i "$KEY_NAME.pem" app.py ubuntu@$EC2_PUBLIC_IP:/home/ubuntu/flask-app/
```

```bash
ssh -i "$KEY_NAME.pem" -o StrictHostKeyChecking=no ubuntu@$EC2_PUBLIC_IP "ls -l /home/ubuntu/flask-app"

```

```bash
echo "✅ app.py copied to EC2 instance: $EC2_PUBLIC_IP:/home/ubuntu/flask-app"
```

```bash
#!/bin/bash

# Ensure environment variables are set
: "${S3_FRONTEND_BUCKET:?Please export S3_FRONTEND_BUCKET before running the script}"
: "${EC2_PUBLIC_IP:?Please export EC2_PUBLIC_IP before running the script}"
REGION="us-east-1"
echo "🚀 Deploying frontend to S3 bucket: $S3_FRONTEND_BUCKET"

# 1. Check if bucket exists
BUCKET_EXISTS=$(aws s3api head-bucket --bucket "$S3_FRONTEND_BUCKET" 2>/dev/null && echo "yes" || echo "no")

# 2. Create the bucket
if [ "$BUCKET_EXISTS" == "yes" ]; then
    echo "⚠️ Bucket already exists: $S3_FRONTEND_BUCKET"
else
    echo "⏳ Creating S3 bucket: $S3_FRONTEND_BUCKET in region $REGION"
    if [ "$REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$S3_FRONTEND_BUCKET" --region "$REGION" --no-cli-pager
    else
        aws s3api create-bucket --bucket "$S3_FRONTEND_BUCKET" --region "$REGION" \
            --create-bucket-configuration LocationConstraint=$REGION --no-cli-pager
    fi
    echo "✅ Bucket created: $S3_FRONTEND_BUCKET"
fi

aws s3api put-public-access-block \
    --bucket "$S3_FRONTEND_BUCKET" \
    --public-access-block-configuration BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false


# 3. Enable static website hosting
aws s3 website s3://"$S3_FRONTEND_BUCKET"/ --index-document index.html

# 4. Download index.html from Github

if rm -f index.html 2>/dev/null; then
    echo "🗑️ Removed existing index.html"
else
    echo "ℹ️ No existing index.html found, continuing..."
fi
echo "⏳ Downloading index.html from Github"

curl -s -L https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/frontend/index.html -o index.html

# 5. Replace placeholder API_BASE with EC2_PUBLIC_IP
sed -i "s|http://<EC2IP>:5000|http://$EC2_PUBLIC_IP:5000|g" index.html

# 6. Upload index.html to S3
aws s3 cp index.html s3://"$S3_FRONTEND_BUCKET"/index.html

# 7. Attach bucket policy for public read access
POLICY=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$S3_FRONTEND_BUCKET/*"
        }
    ]
}
EOF
)

aws s3api put-bucket-policy --bucket "$S3_FRONTEND_BUCKET" --policy "$POLICY" --no-cli-pager

echo "✅ Frontend deployed and accessible at:"
echo "http://$S3_FRONTEND_BUCKET.s3-website-us-east-1.amazonaws.com"
```


```bash

#!/bin/bash

# Variables
DB_SG_NAME="demo-app-db-sg"             # RDS security group name
APP_SG_NAME="demo-app-test-ami-builder-sg"  # EC2 security group name
REGION="us-east-1"

echo "🚀 Updating DB Security Group ($DB_SG_NAME) to allow EC2 SG ($APP_SG_NAME) access on port 3306"

# Get SG IDs from names
DB_SG_ID=$(aws ec2 describe-security-groups --region $REGION --filters Name=group-name,Values="$DB_SG_NAME" --query "SecurityGroups[0].GroupId" --output text)
APP_SG_ID=$(aws ec2 describe-security-groups --region $REGION --filters Name=group-name,Values="$APP_SG_NAME" --query "SecurityGroups[0].GroupId" --output text)

# Check if rule already exists
EXISTING_RULE=$(aws ec2 describe-security-groups \
    --group-ids "$DB_SG_ID" \
    --query "SecurityGroups[0].IpPermissions[?FromPort==\`3306\` && ToPort==\`3306\` && UserIdGroupPairs[0].GroupId=='$APP_SG_ID']" \
    --output text)

if [ -n "$EXISTING_RULE" ]; then
    echo "⚠️ Rule already exists: $APP_SG_NAME can access $DB_SG_NAME on port 3306"
else
    # Add ingress rule
    aws ec2 authorize-security-group-ingress \
        --group-id "$DB_SG_ID" \
        --protocol tcp \
        --port 3306 \
        --source-group "$APP_SG_ID" \
        --region $REGION --no-cli-pager
    echo "✅ Ingress rule added: $APP_SG_NAME can now access $DB_SG_NAME on port 3306"
fi
```

```bash
export EC2_PUBLIC_IP="<YOU-demo-app-test-ami-builder-EC2-INSTANCE-PUBLIC-IP>"
```

```bash
export KEY_NAME="demo-app-private-key"
```

```bash
#!/bin/bash

# Ensure environment variables are set
: "${EC2_PUBLIC_IP:?Please export EC2_PUBLIC_IP before running the script}"
: "${KEY_NAME:?Please export KEY_NAME before running the script}" 

APP_DIR="/home/ubuntu/flask-app"
VENV_DIR="/home/ubuntu/venv"

echo "🚀 Deploying Flask backend to EC2: $EC2_PUBLIC_IP"

# 2. Ensure global venv exists and install dependencies
ssh -i "$KEY_NAME.pem" ubuntu@$EC2_PUBLIC_IP <<EOF
if [ ! -d "$VENV_DIR" ]; then
    echo "⏳ Creating global Python venv at $VENV_DIR"
    python3 -m venv $VENV_DIR
fi

# 6. Start Flask app on EC2 using global venv
ssh -i "$KEY_NAME.pem" ubuntu@$EC2_PUBLIC_IP <<EOF
echo "⏳ Starting Flask app"
cd $APP_DIR
source $VENV_DIR/bin/activate
nohup python app.py > flask.log 2>&1 &
echo "✅ Flask backend is running. Logs: $APP_DIR/flask.log"
EOF

echo "✅ Deployment completed. Access your backend at http://$EC2_PUBLIC_IP:5000"
```


NOTE: TESTING PENDING
```bash
#!/bin/bash
set -e

# -----------------------------
# Automated Systemd Setup for Flask
# -----------------------------

# Required environment variables
: "${EC2_PUBLIC_IP:?Please export EC2_PUBLIC_IP}"
: "${KEY_NAME:?Please export KEY_NAME}"  # without .pem

APP_DIR="/home/ubuntu/flask-app"
VENV_DIR="/home/ubuntu/venv"
SERVICE_NAME="flask-app"

echo "🚀 Setting up Flask as a systemd service on $EC2_PUBLIC_IP"

ssh -i "$KEY_NAME.pem" -o StrictHostKeyChecking=no ubuntu@$EC2_PUBLIC_IP <<EOF
set -e

# -----------------------------
# 1️⃣ Create systemd service file
# -----------------------------
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

echo "📝 Creating systemd service file: \$SERVICE_FILE"
sudo tee \$SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Flask Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=$APP_DIR
ExecStart=$VENV_DIR/bin/python3 $APP_DIR/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# -----------------------------
# 2️⃣ Reload systemd, enable, start service
# -----------------------------
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl restart $SERVICE_NAME

echo "ℹ️ $SERVICE_NAME status:"
sudo systemctl status $SERVICE_NAME --no-pager

# Verify process is running
if pgrep -f 'python app.py' >/dev/null; then
    echo "✅ Flask app is running as a systemd service"
else
    echo "❌ Flask app is NOT running"
fi
EOF

echo "✅ Flask systemd service setup completed on $EC2_PUBLIC_IP"
echo "🌐 Access your backend at http://$EC2_PUBLIC_IP:5000"

```
</details>

---

### ✅ Validation (Check if Resource Created Correctly)
<details> <summary>Validate the Resource</summary> 

> After creating resources (either via AWS Console or AWS CLI), validate them using the pre-built script.
> Run the following in CloudShell:

```bash
export RDS_HOST="<YOUR-my-demo-db.ENDPOINT"
```

```bash
export RDS_USER="admin"
```

```bash
export RDS_PASSWORD="<YOUR-my-demo-db.PASSWORD>"
```

```bash
export S3_BACKEND_BUCKET="demo-app-backend-s3-bucket-12345"
```

```bash
export EC2_PUBLIC_IP="<YOU-demo-app-test-ami-builder-EC2-INSTANCE-PUBLIC-IP>"
```

```bash
export KEY_NAME="demo-app-private-key"
```

```bash
export S3_FRONTEND_BUCKET="demo-app-frontend-s3-bucket-67890"
```

```bash
# Download the validation script from GitHub
curl -O https://raw.githubusercontent.com/shivalkarrahul/demo-three-tier-app-on-aws/main/resource-validation-scripts/6-validate-flask-application.sh

# Make it executable
chmod +x 6-validate-flask-application.sh

# Run the script
./6-validate-flask-application.sh

```

</details>

---

## Part 7: Create an AMI, Launch Template, and Auto Scaling Group

<details>
<summary>📖 Theory: Immutable Infrastructure and Automated Scaling</summary>

In this step, we prepare the infrastructure for scalable deployment of the Flask application:  
• We create an Amazon Machine Image (AMI) from our configured EC2 instance.  
• We define a Launch Template instead of a Launch Configuration (as it’s the modern and recommended approach).  
• Finally, we set up an Auto Scaling Group (ASG) to handle automatic scaling and fault tolerance.

---

#### Detailed Explanation

**Immutable Infrastructure**  
Immutable infrastructure means that instead of modifying existing servers, we create a new, pre-configured image and launch new servers from it. This ensures consistency, avoids configuration drift, and provides predictable environments.

**Amazon Machine Image (AMI)**  
An AMI is a snapshot of a server containing the operating system, application code, and dependencies. By using the same AMI, we can spin up multiple identical servers, ensuring uniformity across environments.

**Launch Template**  
A Launch Template acts as a reusable blueprint for creating EC2 instances. It defines:  
- The AMI ID to use  
- Instance type (CPU/memory configuration)  
- Security Groups and networking details  
- User Data scripts to initialize the application  

Since Launch Templates are versioned, we can easily roll out updates or roll back to previous versions.

**Auto Scaling Group (ASG)**  
The ASG is responsible for maintaining application availability and elasticity. It:  
- Launches new instances when demand increases  
- Terminates instances when demand decreases  
- Replaces unhealthy instances automatically  

By combining AMIs, Launch Templates, and ASGs, we create a **self-healing, auto-scaling infrastructure** that’s production-ready and highly resilient.

---

✅ This setup ensures that our Flask application can scale dynamically based on demand while maintaining consistency and reliability.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 1. Create an AMI from the Running EC2 Instance

#### 1.1 Stop the Flask Application
Before creating an AMI, stop the Flask app service running on the `demo-app-test-ami-builder` instance:
```bash
sudo systemctl stop flask-app
```

#### 1.2 Create an AMI from the Running Instance

1. Go to AWS Console → **EC2 Dashboard**
2. Select the running instance `demo-app-test-ami-builder`
3. Click **Actions → Image and templates → Create Image**
4. Provide an **Image Name** (e.g., `demo-app-ami`)
5. Enable **No Reboot** (optional but recommended)
6. Click **Add new tag**:  
   - **Key:** `Name`
   - **Value:** `demo-app-ami` 
7. Click **Create Image**

#### 1.3 Verify AMI Creation

1. Navigate to EC2 Dashboard → **AMIs**
2. Wait until the AMI status changes to `available`

### 2. Create a Launch Template

A Launch Template defines how instances are launched with predefined configurations.

#### 2.1 Open Launch Template Wizard

1. Go to EC2 Dashboard → **Launch Templates**
2. Click **Create Launch Template**

#### 2.2 Configure Launch Template

* **Template Name:** `demo-app-launch-template`
* **AMI ID:** Select the AMI created above (`demo-app-ami`) from **MyAMIs**
* **Instance Type:** `t2.micro` (or as per requirement)
* **Key pair name:** `demo-app-private-key`
* **Subnet:** Do not select (ASG will select subnets)
* **Security Group:** Select **Create security group** and do not specify rules now (configure them later), just specify the name now

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
* Click **Next**
* **VPC and Subnets:**

  * VPC: `demo-app-vpc`
  * Subnets (Private): `demo-app-private-subnet-1`, `demo-app-private-subnet-2`, `demo-app-private-subnet-3`

* Click **Next** and go to **Configure group size and scaling - optional** page

#### 3.3 Configure group size and scaling - optional 

* **Desired Capacity:** = 2
* **Min Instances:** = 1
* **Max Instances:** = 3
* **Automatic scaling:** = Target tracking scaling policy
* **Scaling policy name** = **Target Tracking Policy**
* **Metric type** = Average CPU Utilization
* **Target value** = 80
* **Instance warmup** = 300 

* Click **Next** and go to **Add tags - optional** page

#### 3.4 Add tags - optional

* **Key:** `Name`

* **Value:** `app-demo-asg-instances`

* Click **Next** and go to **Review** page

* Review & Click **Create Auto Scaling group**

### 4. Verify ASG Setup

#### 4.1 Check if ASG Launches Instances

* Go to **EC2 Dashboard → Instances**
* Confirm that new instances are being launched by the ASG

#### 4.2 Verify New Instances

* Check the **Launch Time** of the instances to confirm they are newly created
* Verify that the **IAM Role** (`demo-app-s3-dynamo-iam-role`) is attached to the instances. Select one instance → Action → Security →Modify IAM Role. Here you should be able to see `demo-app-s3-dynamo-iam-role` attached to the instance.

---

## Part 8: Attach Load Balancer to Auto Scaling Group (ASG)

<details>
<summary>📖 Theory: High Availability and Traffic Management</summary>

In this step, we make the Flask application **highly available and fault-tolerant**:  
• We configure an **Application Load Balancer (ALB)** to handle all incoming traffic.  
• We create a **Target Group (TG)** to manage our EC2 instances and their health.  
• The ALB distributes traffic only to healthy instances in the **Auto Scaling Group (ASG)**, ensuring seamless availability.

---

#### Detailed Explanation

**Application Load Balancer (ALB)**  
An ALB acts as a single entry point for users. It distributes incoming requests across multiple EC2 instances in the ASG. By spreading traffic, it prevents any single instance from being overloaded and ensures consistent application responsiveness.

**Target Group (TG)**  
A Target Group is a collection of EC2 instances registered under the ALB.  
- The ALB forwards incoming traffic to this group.  
- The TG performs **health checks** on each instance.  
- If an instance fails a health check, the TG automatically stops routing traffic to it until it is healthy again or replaced by the ASG.  

**Auto Scaling Group (ASG) Integration**  
The ASG works with the ALB and TG to maintain a resilient setup:  
- The ASG ensures the desired number of instances is always running.  
- If an instance becomes unhealthy, the ASG replaces it.  
- The ALB and TG seamlessly route traffic only to healthy instances.  

---

✅ Together, the **ALB, Target Group, and Auto Scaling Group** create a **self-healing, highly available system** that can handle increased user load and maintain uptime even in the event of failures.

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

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
- Click **Add new tag**:  
   - **Key:** `Name`
   - **Value:** `demo-app-tg` 

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
   - **Inbound Rule:** Port 80, Source: Anywhere-IPV4  
3. Click **Create security group**   

#### 2.2 Create the ALB
1. Go to EC2 Dashboard → **Load Balancers** → **Create Load Balancer**  
2. Select **Application Load Balancer (ALB)**  

**Configure basic details:**  
- **Name:** `demo-app-alb`  
- **Scheme:** Internet-facing  
- **IP address type:** IPv4  
- **VPC:** `demo-app-vpc`  
- **Availability Zones:** Select public subnets: tick check-boxes `us-east-1a (use1-az1)`, `us-east-1b (use1-az2)`, `us-east-1c (use1-az4)` and select `demo-app-public-subnet-1`, `demo-app-public-subnet-2`, `demo-app-public-subnet-3` resepetively.

**Configure Security Groups:**  
- Use the SG created above: `demo-app-lb-sg` and remove the `default` SG.

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

1. Go to **EC2 Dashboard** → **Target Groups** → Select `demo-app-tg`.
2. Click on **Targets** → The ASG instances will appear here, but they will likely show as **unhealthy**.

   * This happens because:

     * The ASG Security Group (`demo-app-lt-asg-sg`) does not have access from the Load Balancer Security Group (`demo-app-lb-sg`) on port `5000`.
     * The DB Security Group (`demo-app-db-sg`) does not have access from the ASG Security Group (`demo-app-lt-asg-sg`) on port `3306`.

### ✅ Steps to Fix

1. **Allow ASG demo-app-lt-asg-sg to connect from Load Balancer demo-app-lb-sg**

   - Go to **EC2** → **Security Groups** → search the `demo-app-lt-asg-sg` security group.
   - **Inbound rule** → **Edit inbound rule** → **Add rule** → Port range `5000` from the `demo-app-lb-sg` security group → Save rule.


2. **Allow DB demo-app-db-sg to connect from ASG demo-app-lt-asg-sg**

   - Go to **EC2** → **Security Groups** → search the `demo-app-db-sg` security group.
   - **Inbound rule** → **Edit inbound rule** → **Add rule** → Port range `3306` from the `demo-app-lt-asg-sg` security group → Save rule.


3. **Terminate existing ASG instances**

   * Go to **EC2 Console** → **Instances**.
   * In the search bar, filter by `Name = app-demo-asg-instances`.
   * Select all → **Instance state → Terminate instance** → Confirm.

4. **Let ASG launch new instances**

   * The Auto Scaling Group will replace the terminated instances.
   * The new instances will now connect to both the Load Balancer and RDS successfully.

5. **Test the Load Balancer URL**

   * Go to **EC2** → **Load Balancers** → select `demo-app-lb`.
   * Copy the **DNS Name**.
   * Open a browser → `http://<ALB-DNS-Name>`.
   * Your Flask app should load correctly and show.

   ```
   {
     "message": "Service is healthy",
     "status": "ok"
   }
   ```

![App UI ALB ](artifacts/app-ui-lb.png)


### 5. Update `index.html`
Since the frontend is hosted on S3 and the backend is now behind the ALB:  
1. Update `API_BASE` in `index.html` to point to `http://<ALB-DNS-Name>`

   * Find the line with:

     ```javascript
     const API_BASE =
     ```
   * Replace `<EC2IP>:5000` with your Load Balancer DNS, for example:

     ```javascript
     const API_BASE = "http://demo-app-alb-1294615632.us-east-1.elb.amazonaws.com";
     ```

2. Re-upload `index.html` to the frontend S3 bucket (e.g., `demo-app-frontend-s3-bucket-6789`)  
3. Access the S3 website URL and verify the frontend connects to the backend via the ALB

![App UI ALB ](artifacts/app-ui-after-lb.png)

---

## Part 9 Security Groups Overview

A total of **5 Security Groups** were created to manage access between different components of the application.

| **Security Group**                 | **Purpose**                                | **Inbound Rules**                                                                                                                                                                                                     |
| ---------------------------------- | ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`demo-app-lt-asg-sg`**           | Used by Auto Scaling Group (ASG) instances | - Port **5000** from `demo-app-lb-sg` (ALB)<br>- Port **22** from `demo-app-bastion-host-sg`                                                                                                                          |
| **`demo-app-bastion-host-sg`**     | Bastion host to SSH into private instances | - Port **22** from `0.0.0.0/0`                                                                                                                                                                                        |
| **`demo-app-test-ami-builder-sg`** | For building AMIs and test access          | - Port **5000** from `0.0.0.0/0`<br>- Port **22** from `0.0.0.0/0`                                                                                                                                                    |
| **`demo-app-lb-sg`**               | Application Load Balancer (ALB)            | - Port **80** from `0.0.0.0/0`                                                                                                                                                                                        |
| **`demo-app-db-sg`**               | RDS MySQL database                         | - Port **3306** from `demo-app-lt-asg-sg` (ASG)<br>- Port **3306** from `demo-app-test-ami-builder-sg` (for initial testing)<br>- Port **3306** from `152.58.11.96/32` (your IP; optional, not really required) |

⚠️ **Note:**

* The rule allowing your **personal IP (`152.58.11.96/32`)** into `demo-app-db-sg` is not manual; it is added by AWS when creating a new SG for RDS.
* For security best practices, always keep SSH (port 22) restricted to known IPs instead of `0.0.0.0/0`.

#### Screenshots  

##### 1. demo-app-lt-asg-sg Rules
![demo-app-lt-asg-sg](artifacts/demo-app-lt-asg-sg.png)

##### 2. demo-app-bastion-host-sg Rules
![demo-app-bastion-host-sg](artifacts/demo-app-bastion-host-sg.png)

##### 3. demo-app-test-ami-builder-sg Rules
![demo-app-test-ami-builder-sg](artifacts/demo-app-test-ami-builder-sg.png)

##### 4. demo-app-lb-sg Rules
![demo-app-lb-sg](artifacts/demo-app-lb-sg.png)

##### 5. demo-app-db-sg Rules
![demo-app-db-sg](artifacts/demo-app-db-sg.png)

---

## Part 10: Create a Bastion Host in Public Subnet to Access Instances in Private Subnet

<details>
<summary>📖 Theory: Secure Access to Private Resources</summary>

In this step, we configure a **Bastion Host** (public EC2 instance) to securely access and manage private instances:  
• Private servers (application servers, databases) stay isolated in private subnets.  
• A **Bastion Host** in the public subnet acts as the single secure entry point.  
• Administrators first connect to the Bastion Host, then securely tunnel into private resources.  

---

#### Detailed Explanation

**Private Subnets and Security**  
Private subnets ensure that sensitive resources (like application servers and RDS databases) are not directly exposed to the internet. This strengthens security but creates the challenge of how administrators can access these instances when needed.  

**Bastion Host (Jump Server)**  
A Bastion Host is a hardened EC2 instance in a **public subnet** with controlled SSH (port 22) access.  
- It serves as the only externally accessible point for administrators.  
- From the Bastion Host, admins can securely "jump" into private instances via SSH.  
- This minimizes the attack surface by avoiding direct internet access to all private instances.  

**Workflow**  
1. Administrator connects to the Bastion Host over SSH.  
2. From the Bastion Host, the administrator initiates a second SSH session into the target private instance.  
3. This setup forms a secure, controlled tunnel for managing private resources.  

---

✅ Using a Bastion Host provides **centralized, auditable, and secure access** to private infrastructure while keeping critical resources hidden from the public internet.  

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

### 2. Launch an EC2 Instance (Bastion Host)
1. Open AWS EC2 Console → **Launch Instance**.
2. Enter **Instance Name:** `demo-app-bastion-host`.
3. Choose AMI: Ubuntu Server 24.04 LTS (HVM), SSD Volume Type .
4. Instance Type: `t2.micro` (free-tier) or as required.
5. Key Pair: Create or select an existing key pair (download `.pem` for terminal(Linux/Mac), `.ppk` for Putty(Windows)).  
   Name: `demo-app-private-key`.
6. Network → Edit : Select your `demo-app-vpc` VPC → Subnet: `demo-app-public-subnet-1`.
7. Enable `Auto-assign Public IP`.
8. Security Group: Create or select:  
   - Name: `demo-app-bastion-host-sg`  
   - Allow SSH (22) from Anywhere (Not recommended in Production, ok for Testing)
10. Launch the instance and copy the **Public IP**.

---

## Part 11: Connect From Bastion Host to Private Instance

<details>
<summary>📖 Theory: Secure Access and Debugging with Bastion Hosts</summary>

In this step, we use the **Bastion Host** to securely access and debug private EC2 instances:  
• All administrative access flows only through the Bastion Host.  
• SCP is used to copy private keys to the Bastion Host for authentication.  
• SSH connections from Bastion to private instances allow secure management.  
• Debugging and troubleshooting can be done without exposing private servers to the internet.  

---

#### Detailed Explanation

**Centralized Access Control**  
The Bastion Host acts as the **single point of entry** for managing private EC2 instances. This ensures that administrators never connect to private servers directly from the internet, reducing the risk of unauthorized access.  

**Authentication Workflow**  
1. The administrator copies the necessary private key to the Bastion Host using **SCP (Secure Copy Protocol)**.  
2. From the Bastion Host, the administrator initiates a secure **SSH session** to the private instance using its private IP address.  
3. Security groups are configured so that SSH (port 22) access to private instances is only allowed from the Bastion Host’s security group.  

**Debugging and Maintenance**  
Once connected to the private EC2 instance via the Bastion Host, administrators can:  
- Use `journalctl` to view application and system logs.  
- Use `systemctl` to manage services like the Flask application.  
- Run diagnostic commands safely within the private environment.  

---

✅ This setup enforces **secure, controlled, and auditable management access** while enabling effective debugging of private infrastructure.  

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### 1. Copy the Private Key to Bastion Host
**From Terminal (Linux/Mac):**  
```bash
scp -vvv -i ~/Downloads/demo-app-private-key.pem ~/Downloads/demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>:/home/ubuntu/
```

**From Windows:**

* Use a tool like **WinSCP** and upload the private key to `/home/ubuntu/` directory on the Bastion Host.

### 2. Update ASG Security Group

   - Go to **EC2** → **Security Groups** → search the `demo-app-lt-asg-sg` security group.
   - **Inbound rule** → **Edit inbound rule** → **Add rule** → Port range `22` from the `demo-app-bastion-host-sg` security group → Save rule.

### 3. Connect to the Bastion Host

**Terminal (Linux/Mac):**

```bash
chmod 400 ~/Downloads/demo-app-private-key.pem
```

```bash
ssh -i ~/Downloads/demo-app-private-key.pem ubuntu@<BASTION_PUBLIC_IP>
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
2. Check the applications running and their port details. You should see a service running on ort 5000. This is our Flask App running on Port 5000

```bash
netstat -tulpn
```

```
.
.
tcp        0      0 0.0.0.0:5000            0.0.0.0:*               LISTEN      572/python3      
.
.
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

## Part 12: Cleanup – Terminate All Resources

### 📖 Theory
<details> <summary>Understanding the Resource Cleanup</summary> 

In this step, we clean up all AWS resources after testing the three-tier application:   

---

#### Detailed Explanation

**Cost Management**  
A fundamental principle of cloud computing is **paying only for what you use**. Leaving resources running unnecessarily can lead to unexpected costs. Cleaning up your AWS environment ensures that you are only billed for active resources.  

**Simplified Management**  
A clean environment is easier to manage and reduces the chance of misconfiguration or conflicts with future projects.  

**Dependency-Based Cleanup Order**  
AWS resources often depend on each other. To avoid errors during deletion, follow a specific order:  

<p align="left"><b>🔒 Theory section ends here — continue with hands-on steps ⬇️</b></p>

</details>

---

### ⚡ AWS CLI (Alternate to AWS Console – Save Some Clicks)

<details> <summary>Part 6: Flask Application Resources Cleanup (AWS CLI)</summary> 

> Run these AWS CLI commands to quickly delete the resource without navigating the Console.

Change value of S3_FRONTEND_BUCKET variable with your S3_FRONTEND_BUCKET Name

```bash
export S3_FRONTEND_BUCKET="demo-app-frontend-s3-bucket-67890"
```

```bash
#!/bin/bash
set -e

# -----------------------------
# Targeted Cleanup Script
# -----------------------------

# Ensure required environment variables
: "${S3_FRONTEND_BUCKET:?Please export S3_FRONTEND_BUCKET}"

INSTANCE_NAME="demo-app-test-ami-builder"
DB_SG_NAME="demo-app-db-sg"
APP_SG_NAME="demo-app-test-ami-builder-sg"
ROLE_NAME="demo-app-s3-dynamo-iam-role"
INSTANCE_PROFILE_NAME="$ROLE_NAME"
KEY_NAME="demo-app-private-key"
REGION="us-east-1"

echo "🧹 Starting targeted cleanup..."

# -----------------------------
# 1️⃣ Terminate EC2 instance
# -----------------------------
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
    --query "Reservations[0].Instances[0].InstanceId" --output text 2>/dev/null)

if [ -n "$INSTANCE_ID" ] && [ "$INSTANCE_ID" != "None" ]; then
    echo "🛑 Terminating EC2 instance: $INSTANCE_NAME ($INSTANCE_ID)"
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
    echo "✅ EC2 instance terminated"
else
    echo "ℹ️ No EC2 instance found: $INSTANCE_NAME"
fi

# -----------------------------
# 2️⃣ Delete key pair
# -----------------------------
if aws ec2 describe-key-pairs --key-names $KEY_NAME &>/dev/null; then
    echo "🗑️ Deleting key pair: $KEY_NAME"
    aws ec2 delete-key-pair --key-name $KEY_NAME
    rm -f $KEY_NAME.pem
    echo "✅ Key pair deleted"
else
    echo "ℹ️ No key pair found: $KEY_NAME"
fi

# -----------------------------
# 3️⃣ Delete Security Groups
# -----------------------------
DB_SG_ID=$(aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=$DB_SG_NAME" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
APP_SG_ID=$(aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=$APP_SG_NAME" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

# Revoke ingress rule if both SGs exist
if [ -n "$DB_SG_ID" ] && [ -n "$APP_SG_ID" ] && [ "$DB_SG_ID" != "None" ] && [ "$APP_SG_ID" != "None" ]; then
    echo "🗑️ Removing ingress rule from $DB_SG_NAME allowing $APP_SG_NAME access on port 3306"
    aws ec2 revoke-security-group-ingress \
        --group-id "$DB_SG_ID" \
        --protocol tcp \
        --port 3306 \
        --source-group "$APP_SG_ID" \
        --region $REGION || echo "⚠️ No ingress rule to remove"
    echo "✅ Ingress rule removed"
else
    echo "ℹ️ Skipping ingress removal: one or both SGs not found"
fi

# Delete Security Groups
for SG_NAME in "$APP_SG_NAME"; do
    SG_ID=$(aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=$SG_NAME" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
    if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
        echo "🗑️ Deleting Security Group: $SG_NAME ($SG_ID)"
        aws ec2 delete-security-group --group-id "$SG_ID" 2>/dev/null && echo "✅ Deleted $SG_NAME" || echo "⚠️ Could not delete $SG_NAME (check dependencies)"
    else
        echo "ℹ️ Security Group not found: $SG_NAME"
    fi
done

# -----------------------------
# 4️⃣ Detach policies & delete IAM Role + Instance Profile
# -----------------------------

# Detach all attached managed policies dynamically
ATTACHED_POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query "AttachedPolicies[].PolicyArn" --output text 2>/dev/null || echo "")
if [ -n "$ATTACHED_POLICIES" ]; then
    for P in $ATTACHED_POLICIES; do
        echo "🔗 Detaching managed policy $P from $ROLE_NAME"
        aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$P" 2>/dev/null || echo "⚠️ Could not detach $P"
    done
else
    echo "ℹ️ No managed policies attached to $ROLE_NAME"
fi


if aws iam get-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" &>/dev/null; then
    echo "🗑️ Removing role from instance profile: $INSTANCE_PROFILE_NAME"
    aws iam remove-role-from-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" --role-name "$ROLE_NAME" 2>/dev/null || echo "⚠️ Role not attached to instance profile"
    aws iam delete-instance-profile --instance-profile-name "$INSTANCE_PROFILE_NAME" 2>/dev/null || echo "⚠️ Could not delete instance profile"
fi

if aws iam get-role --role-name $ROLE_NAME &>/dev/null; then
    echo "🗑️ Deleting IAM Role: $ROLE_NAME"
    aws iam delete-role --role-name $ROLE_NAME
    echo "✅ IAM Role deleted"
else
    echo "ℹ️ IAM Role not found: $ROLE_NAME"
fi

# -----------------------------
# 5️⃣ Delete frontend S3 bucket
# -----------------------------
if aws s3 ls "s3://$S3_FRONTEND_BUCKET" &>/dev/null; then
    echo "🗑️ Deleting frontend S3 bucket and all contents: $S3_FRONTEND_BUCKET"
    aws s3 rm "s3://$S3_FRONTEND_BUCKET" --recursive
    aws s3api delete-bucket --bucket "$S3_FRONTEND_BUCKET"
    echo "✅ Frontend S3 bucket deleted"
else
    echo "ℹ️ Frontend S3 bucket not found: $S3_FRONTEND_BUCKET"
fi

echo "🧹 Targeted cleanup completed!"

```

</details>

---

<details> <summary>Part 5: DynamoDB Table and Lambda Resources Cleanup (AWS CLI)</summary> 

> Run these AWS CLI commands to quickly delete the resource without navigating the Console.


```bash
ROLE_NAME="demo-app-lambda-iam-role"
DDB_TABLE_NAME="demo-app-file-metadata-dynamodb"
LAMBDA_NAME="demo-app-metadata-lambda"

# Delete DynamoDB Table
DDB_TABLE=$(aws dynamodb describe-table --table-name "$DDB_TABLE_NAME" --query "Table.TableName" --output text 2>/dev/null)

if [ -z "$DDB_TABLE" ] || [ "$DDB_TABLE" == "None" ]; then
    echo "⚠️ DynamoDB Table $DDB_TABLE_NAME not found. Skipping deletion."
else
    aws dynamodb delete-table --table-name "$DDB_TABLE_NAME" --no-cli-pager
    echo "✅ DynamoDB Table deleted: $DDB_TABLE_NAME"
fi

# Fetch Lambda ARN
LAMBDA_ARN=$(aws lambda get-function --function-name "$LAMBDA_NAME" --query 'Configuration.FunctionArn' --output text 2>/dev/null)

if [ -z "$LAMBDA_ARN" ] || [ "$LAMBDA_ARN" == "None" ]; then
    echo "⚠️ Lambda function $LAMBDA_NAME not found. Skipping deletion."
else
    # Unsubscribe Lambda from any existing SNS topics
    SUBSCRIPTION_ARNS=$(aws sns list-subscriptions | jq -r ".Subscriptions[] | select(.Endpoint==\"$LAMBDA_ARN\") | .SubscriptionArn")
    for SUB_ARN in $SUBSCRIPTION_ARNS; do
        aws sns unsubscribe --subscription-arn "$SUB_ARN" --no-cli-pager
        echo "✅ Unsubscribed Lambda from SNS subscription: $SUB_ARN"
    done

    # Delete Lambda Function
    aws lambda delete-function --function-name "$LAMBDA_NAME" --no-cli-pager
    echo "✅ Lambda function deleted: $LAMBDA_NAME"
fi

# Delete IAM Role for Lambda
ROLE_EXISTS=$(aws iam get-role --role-name "$ROLE_NAME" --query 'Role.RoleName' --output text 2>/dev/null)

if [ -z "$ROLE_EXISTS" ] || [ "$ROLE_EXISTS" == "None" ]; then
    echo "⚠️ IAM Role $ROLE_NAME not found. Skipping deletion."
else
    # Detach all attached policies
    POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query 'AttachedPolicies[].PolicyArn' --output text)
    for POLICY_ARN in $POLICIES; do
        aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn "$POLICY_ARN" --no-cli-pager
        echo "✅ Detached policy: $POLICY_ARN"
    done

    # Delete the role
    aws iam delete-role --role-name "$ROLE_NAME" --no-cli-pager
    echo "✅ IAM Role deleted: $ROLE_NAME"
fi

```
</details>

---

<details> <summary>Part 4: SNS Resources Cleanup  (AWS CLI)</summary> 

> Run these AWS CLI commands to quickly delete the resource without navigating the Console.


```bash
SNS_TOPIC_NAME="demo-app-sns-topic"
S3_BUCKET_NAME="demo-app-backend-s3-bucket-12345"

# Delete S3 Bucket Notification
echo "Removing event notifications from S3 bucket: $S3_BUCKET_NAME"

aws s3api put-bucket-notification-configuration \
    --bucket $S3_BUCKET_NAME \
    --notification-configuration '{}' --no-cli-pager

echo "✅ Event notifications removed from S3 bucket: $S3_BUCKET_NAME"

# Unsubscribe all emails from SNS Topic

SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)

if [ "$SNS_TOPIC_ARN" == "None" ] || [ -z "$SNS_TOPIC_ARN" ]; then
    echo "⚠️ SNS Topic $SNS_TOPIC_NAME not found"
else
    echo "Fetching subscriptions for SNS Topic: $SNS_TOPIC_NAME"
    SUBSCRIPTION_ARNS=$(aws sns list-subscriptions-by-topic --topic-arn $SNS_TOPIC_ARN --query "Subscriptions[].SubscriptionArn" --output text)

   for SUB_ARN in $SUBSCRIPTION_ARNS; do
      if [ "$SUB_ARN" == "PendingConfirmation" ]; then
         echo "⚠️ Subscription pending confirmation, cannot unsubscribe: $SUB_ARN"
         continue
      fi

      aws sns unsubscribe --subscription-arn $SUB_ARN --no-cli-pager
      echo "✅ Unsubscribed: $SUB_ARN"
   done


    # Delete SNS Topic
    aws sns delete-topic --topic-arn $SNS_TOPIC_ARN --no-cli-pager
    echo "✅ SNS Topic deleted: $SNS_TOPIC_NAME ($SNS_TOPIC_ARN)"
fi

```

</details>

---

<details> <summary>Part 3: S3 Resource Cleanup (AWS CLI)</summary> 

> Run these AWS CLI commands to quickly delete the resource without navigating the Console.


```bash
BUCKET_NAME="demo-app-backend-s3-bucket-12345"
REGION="us-east-1"

echo "Deleting all objects from S3 Bucket: $BUCKET_NAME"

aws s3 rm s3://$BUCKET_NAME --recursive --region $REGION >/dev/null 2>&1

echo "Deleting S3 Bucket: $BUCKET_NAME"
aws s3api delete-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --no-cli-pager >/dev/null 2>&1

# Verify deletion
if aws s3api head-bucket --bucket $BUCKET_NAME 2>/dev/null; then
    echo "⚠️ Failed to delete S3 Bucket: $BUCKET_NAME"
else
    echo "✅ S3 Bucket deleted: $BUCKET_NAME"
fi

```

</details>

---

<details> <summary>Part 2: RDS Resource  Cleanup (AWS CLI)</summary> 

> Run these AWS CLI commands to quickly delete the resource without navigating the Console.


```bash
DB_INSTANCE_ID="my-demo-db"
DB_SUBNET_GROUP_NAME="demo-app-db-subnet-group"
DB_SECURITY_GROUP_NAME="demo-app-db-sg"
REGION="us-east-1"

echo "Deleting RDS Instance: $DB_INSTANCE_ID"

# Delete RDS instance without final snapshot
aws rds delete-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --skip-final-snapshot \
    --region $REGION \
    --no-cli-pager >/dev/null 2>&1

# Wait until instance is deleted
aws rds wait db-instance-deleted \
    --db-instance-identifier $DB_INSTANCE_ID \
    --region $REGION
echo "✅ RDS Instance deleted: $DB_INSTANCE_ID"

# Delete DB Subnet Group
echo "Deleting DB Subnet Group: $DB_SUBNET_GROUP_NAME"
aws rds delete-db-subnet-group \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
    --region $REGION \
    --no-cli-pager >/dev/null 2>&1
echo "✅ DB Subnet Group deleted: $DB_SUBNET_GROUP_NAME"

# Delete Security Group
echo "Deleting Security Group: $DB_SECURITY_GROUP_NAME"
DB_SG_ID=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=$DB_SECURITY_GROUP_NAME \
    --query "SecurityGroups[0].GroupId" \
    --output text --region $REGION)

if [ "$DB_SG_ID" != "None" ]; then
    aws ec2 delete-security-group \
        --group-id $DB_SG_ID \
        --region $REGION \
        --no-cli-pager >/dev/null 2>&1
    echo "✅ Security Group deleted: $DB_SECURITY_GROUP_NAME ($DB_SG_ID)"
else
    echo "⚠️ Security Group not found: $DB_SECURITY_GROUP_NAME"
fi
```

</details>

---

<details> <summary>Part 1: Network Resource Cleanup (AWS CLI)</summary> 

> Run these AWS CLI commands to quickly delete the resource without navigating the Console.


### **1. Delete NAT Gateway**

```bash
echo "Deleting NAT Gateway: demo-app-nat-gateway-1"

# Get the NAT Gateway ID with the given Name AND State=available
NAT_ID=$(aws ec2 describe-nat-gateways \
    --filter "Name=tag:Name,Values=demo-app-nat-gateway-1" \
    --filter "Name=state,Values=available" \
    --query "NatGateways[0].NatGatewayId" \
    --output text --no-cli-pager)

if [ "$NAT_ID" != "None" ] && [ -n "$NAT_ID" ]; then
    # Initiate deletion
    aws ec2 delete-nat-gateway --nat-gateway-id "$NAT_ID" --no-cli-pager
    echo "✅ NAT Gateway deletion initiated: $NAT_ID"

    # Wait until NAT Gateway is fully deleted
    echo "⏳ Waiting for NAT Gateway to be deleted..."
    aws ec2 wait nat-gateway-deleted --nat-gateway-ids "$NAT_ID" --no-cli-pager
    echo "✅ NAT Gateway fully deleted: $NAT_ID"
else
    echo "⚠️ NAT Gateway demo-app-nat-gateway-1 not found in available state"
fi


```

---

### **2. Release Elastic IP**

```bash
echo "Releasing Elastic IP: demo-app-eip-1"
EIP_ALLOC_ID=$(aws ec2 describe-addresses \
    --filters "Name=tag:Name,Values=demo-app-eip-1" \
    --query "Addresses[0].AllocationId" \
    --output text --no-cli-pager)

if [ "$EIP_ALLOC_ID" != "None" ] && [ -n "$EIP_ALLOC_ID" ]; then
    aws ec2 release-address --allocation-id $EIP_ALLOC_ID --no-cli-pager
    echo "✅ Elastic IP released: $EIP_ALLOC_ID"
else
    echo "⚠️ Elastic IP demo-app-eip-1 not found"
fi
```

---

### **3. Detach & Delete Internet Gateway**

```bash
echo "Deleting Internet Gateway: demo-app-igw"
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=demo-app-igw" \
    --query "InternetGateways[0].InternetGatewayId" \
    --output text --no-cli-pager)

if [ "$IGW_ID" != "None" ] && [ -n "$IGW_ID" ]; then
    VPC_ID=$(aws ec2 describe-internet-gateways --internet-gateway-ids $IGW_ID \
        --query "InternetGateways[0].Attachments[0].VpcId" --output text --no-cli-pager)
    aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --no-cli-pager
    aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --no-cli-pager
    echo "✅ Internet Gateway deleted: $IGW_ID"
else
    echo "⚠️ Internet Gateway demo-app-igw not found"
fi
```

---

### **4. Delete Public & Private Route Tables**

```bash
for RT_NAME in demo-app-public-rt demo-app-private-rt-1; do
    echo "Deleting Route Table: $RT_NAME"
    RT_ID=$(aws ec2 describe-route-tables \
        --filters "Name=tag:Name,Values=$RT_NAME" \
        --query "RouteTables[0].RouteTableId" \
        --output text --no-cli-pager)

    if [ "$RT_ID" != "None" ] && [ -n "$RT_ID" ]; then
        # Disassociate any associated subnets
        ASSOCIATIONS=$(aws ec2 describe-route-tables --route-table-ids $RT_ID \
            --query "RouteTables[0].Associations[?Main==\`false\`].RouteTableAssociationId" \
            --output text --no-cli-pager)
        for assoc in $ASSOCIATIONS; do
            aws ec2 disassociate-route-table --association-id $assoc --no-cli-pager
        done
        aws ec2 delete-route-table --route-table-id $RT_ID --no-cli-pager
        echo "✅ Route Table deleted: $RT_NAME ($RT_ID)"
    else
        echo "⚠️ Route Table $RT_NAME not found"
    fi
done
```

---

### **5. Delete Subnets**

```bash
for SUBNET in demo-app-public-subnet-1 demo-app-public-subnet-2 demo-app-public-subnet-3 demo-app-private-subnet-1 demo-app-private-subnet-2 demo-app-private-subnet-3; do
    echo "Deleting Subnet: $SUBNET"
    SUBNET_ID=$(aws ec2 describe-subnets \
        --filters "Name=tag:Name,Values=$SUBNET" \
        --query "Subnets[0].SubnetId" --output text --no-cli-pager)
    
    if [ "$SUBNET_ID" != "None" ] && [ -n "$SUBNET_ID" ]; then
        aws ec2 delete-subnet --subnet-id $SUBNET_ID --no-cli-pager
        echo "✅ Subnet deleted: $SUBNET ($SUBNET_ID)"
    else
        echo "⚠️ Subnet $SUBNET not found"
    fi
done
```

---

### **6. Delete VPC**

```bash
echo "Deleting VPC: demo-app-vpc"
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=demo-app-vpc" \
    --query "Vpcs[0].VpcId" --output text --no-cli-pager)

if [ "$VPC_ID" != "None" ] && [ -n "$VPC_ID" ]; then
    aws ec2 delete-vpc --vpc-id $VPC_ID --no-cli-pager
    echo "✅ VPC deleted: $VPC_ID"
else
    echo "⚠️ VPC demo-app-vpc not found"
fi
```

---

</details>

---
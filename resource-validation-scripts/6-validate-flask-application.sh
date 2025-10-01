#!/bin/bash
# Validation script for demo 3-tier app
# Checks IAM role, EC2, Security Groups, RDS access, S3 buckets, Flask backend, and frontend

echo "🔹💻⚡ Validating 3-Tier Application Deployment..."

# -----------------------------
# 1️⃣ Validate IAM Role & Policies
# -----------------------------
ROLE_NAME="demo-app-s3-dynamo-iam-role"
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query "Role.Arn" --output text 2>/dev/null)

if [ -n "$ROLE_ARN" ] && [ "$ROLE_ARN" != "None" ]; then
    echo "✅ IAM Role exists: $ROLE_NAME ($ROLE_ARN)"
    POLICIES=$(aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query "AttachedPolicies[].PolicyName" --output text)
    [[ $POLICIES == *"AmazonS3FullAccess"* ]] && echo "✅ Policy attached: AmazonS3FullAccess" || echo "❌ Missing policy: AmazonS3FullAccess"
    [[ $POLICIES == *"AmazonDynamoDBReadOnlyAccess"* ]] && echo "✅ Policy attached: AmazonDynamoDBReadOnlyAccess" || echo "❌ Missing policy: AmazonDynamoDBReadOnlyAccess"
else
    echo "❌ IAM Role not found: $ROLE_NAME"
fi

# -----------------------------
# 2️⃣ Validate EC2 Instance
# -----------------------------
INSTANCE_NAME="demo-app-test-ami-builder"
EC2_INFO=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" \
    --query "Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress,KeyName]" --output text 2>/dev/null)

if [ -n "$EC2_INFO" ]; then
    INSTANCE_ID=$(echo $EC2_INFO | awk '{print $1}')
    STATE=$(echo $EC2_INFO | awk '{print $2}')
    PUBLIC_IP=$(echo $EC2_INFO | awk '{print $3}')
    KEY_NAME_INST=$(echo $EC2_INFO | awk '{print $4}')
    echo "✅ EC2 exists: $INSTANCE_NAME ($INSTANCE_ID) - State: $STATE - Public IP: $PUBLIC_IP - Key: $KEY_NAME_INST"
else
    echo "❌ EC2 instance not found: $INSTANCE_NAME"
fi

# -----------------------------
# 3️⃣ Validate Security Groups
# -----------------------------
APP_SG_NAME="demo-app-test-ami-builder-sg"
DB_SG_ID="demo-app-db-sg"

APP_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$APP_SG_NAME" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)
DB_SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$DB_SG_NAME" --query "SecurityGroups[0].GroupId" --output text 2>/dev/null)

if [ -n "$APP_SG_ID" ] && [ "$APP_SG_ID" != "None" ]; then
    echo "✅ App Security Group exists: $APP_SG_NAME ($APP_SG_ID)"
else
    echo "❌ App Security Group missing: $APP_SG_NAME"
fi

if [ -n "$DB_SG_ID" ] && [ "$DB_SG_ID" != "None" ]; then
    echo "✅ DB Security Group exists: $DB_SG_NAME ($DB_SG_ID)"
    # Check ingress 3306 from app SG
    RULE=$(aws ec2 describe-security-groups --group-ids $DB_SG_ID \
        --query "SecurityGroups[0].IpPermissions[?FromPort==\`3306\` && ToPort==\`3306\` && UserIdGroupPairs[0].GroupId=='$APP_SG_ID']" \
        --output text)
    if [ -n "$RULE" ]; then
        echo "✅ Ingress rule exists: $APP_SG_NAME -> $DB_SG_NAME on port 3306"
    else
        echo "❌ Missing ingress rule: $APP_SG_NAME -> $DB_SG_NAME on port 3306"
    fi
else
    echo "❌ DB Security Group missing: $DB_SG_NAME"
fi

# -----------------------------
# 4️⃣ Validate RDS Access
# -----------------------------
: "${RDS_HOST:?Please export RDS_HOST}"
: "${RDS_USER:?Please export RDS_USER}"
: "${RDS_PASSWORD:?Please export RDS_PASSWORD}"

# Run from your local or CloudShell, executes on EC2
ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ubuntu@$EC2_PUBLIC_IP "\
  if nc -z -w5 $RDS_HOST 3306 &>/dev/null; then
      echo '✅ EC2 can reach RDS: $RDS_HOST:3306'
  else
      echo '❌ EC2 cannot reach RDS: $RDS_HOST:3306'
  fi
"

# -----------------------------
# 5️⃣ Validate S3 Buckets
# -----------------------------
: "${S3_BACKEND_BUCKET:?Please export S3_BACKEND_BUCKET}"
: "${S3_FRONTEND_BUCKET:?Please export S3_FRONTEND_BUCKET}"

for BUCKET in $S3_BACKEND_BUCKET $S3_FRONTEND_BUCKET; do
    if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
        echo "✅ S3 Bucket exists: $BUCKET"
    else
        echo "❌ S3 Bucket missing: $BUCKET"
    fi
done

# -----------------------------
# 6️⃣ Validate Flask backend on EC2
# -----------------------------
: "${EC2_PUBLIC_IP:?Please export EC2_PUBLIC_IP}"
: "${KEY_NAME:?Please export KEY_NAME}"

ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ubuntu@$EC2_PUBLIC_IP "test -f /home/ubuntu/flask-app/app.py"

if [ $? -eq 0 ]; then
    echo "✅ Flask backend app.py exists on EC2"
else
    echo "❌ Flask backend app.py missing on EC2"
fi


# Optionally check Flask process running
ssh -o StrictHostKeyChecking=no -i "$KEY_NAME.pem" ubuntu@$EC2_PUBLIC_IP "pgrep -f 'python app.py'"


if [ $? -eq 0 ]; then
    echo "✅ Flask backend is running on EC2"
else
    echo "⚠️ Flask backend not running (check manually)"
fi

# -----------------------------
# 7️⃣ Validate Frontend on S3
# -----------------------------
INDEX_EXISTS=$(aws s3 ls "s3://$S3_FRONTEND_BUCKET/index.html" 2>/dev/null)
if [ -n "$INDEX_EXISTS" ]; then
    echo "✅ Frontend index.html exists in S3 bucket: $S3_FRONTEND_BUCKET"
    echo "🌐 Frontend URL: http://$S3_FRONTEND_BUCKET.s3-website-us-east-1.amazonaws.com"
else
    echo "❌ Frontend index.html missing in S3 bucket: $S3_FRONTEND_BUCKET"
fi

echo "🔹💻⚡ Validation completed."

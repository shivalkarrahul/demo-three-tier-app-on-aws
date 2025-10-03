#!/bin/bash
# ===============================
# Validation Script for Demo App
# ===============================

# -------------------------------
# Variables
# -------------------------------
REGION="us-east-1"
TG_NAME="demo-app-tg"
ALB_NAME="demo-app-alb"
ALB_SG_NAME="demo-app-lb-sg"
ASG_NAME="demo-app-asg"
ASG_SG_NAME="demo-app-lt-asg-sg"
DB_SG_NAME="demo-app-db-sg"
FRONTEND_BUCKET="$FRONTEND_BUCKET"

# -------------------------------
# Function to check required variables
# -------------------------------
check_var() {
    VAR_NAME=$1
    if [ -z "${!VAR_NAME}" ]; then
        echo "⚠️  Environment variable $VAR_NAME is not set."
        exit 1
    fi
}

for VAR in REGION TG_NAME ALB_NAME ALB_SG_NAME ASG_NAME ASG_SG_NAME DB_SG_NAME FRONTEND_BUCKET; do
    check_var "$VAR"
done

# -------------------------------
# 2️⃣ Validate Target Group
# -------------------------------
echo "📌 Validating Target Group: $TG_NAME"
TG_ARN=$(aws elbv2 describe-target-groups \
    --names "$TG_NAME" \
    --query "TargetGroups[0].TargetGroupArn" --output text --region $REGION 2>/dev/null)

if [ -z "$TG_ARN" ] || [ "$TG_ARN" == "None" ]; then
    echo "❌ Target Group not found: $TG_NAME"
else
    echo "✅ Target Group exists: $TG_NAME ($TG_ARN)"
fi

# -------------------------------
# 3️⃣ Validate ALB Security Group
# -------------------------------
echo "📌 Validating ALB Security Group: $ALB_SG_NAME"
ALB_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$ALB_SG_NAME" \
    --query "SecurityGroups[0].GroupId" --output text --region $REGION)

if [ -z "$ALB_SG_ID" ] || [ "$ALB_SG_ID" == "None" ]; then
    echo "❌ ALB Security Group not found: $ALB_SG_NAME"
else
    echo "✅ ALB Security Group exists: $ALB_SG_NAME ($ALB_SG_ID)"
fi

# -------------------------------
# 4️⃣ Validate ALB
# -------------------------------
echo "📌 Validating ALB: $ALB_NAME"
ALB_ARN=$(aws elbv2 describe-load-balancers \
    --names "$ALB_NAME" \
    --query "LoadBalancers[0].LoadBalancerArn" --output text --region $REGION 2>/dev/null)

if [ -z "$ALB_ARN" ] || [ "$ALB_ARN" == "None" ]; then
    echo "❌ ALB not found: $ALB_NAME"
else
    echo "✅ ALB exists: $ALB_NAME ($ALB_ARN)"

    # Validate Listener
    LISTENER_ARN=$(aws elbv2 describe-listeners \
        --load-balancer-arn "$ALB_ARN" \
        --query "Listeners[0].ListenerArn" --output text --region $REGION 2>/dev/null)
    if [ -n "$LISTENER_ARN" ] && [ "$LISTENER_ARN" != "None" ]; then
        echo "✅ Listener exists for ALB: $LISTENER_ARN"
    else
        echo "⚠️ Listener not found for ALB"
    fi
fi

# -------------------------------
# 5️⃣ Validate ASG Security Group
# -------------------------------
echo "📌 Validating ASG Security Group: $ASG_SG_NAME"
ASG_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$ASG_SG_NAME" \
    --query "SecurityGroups[0].GroupId" --output text --region $REGION)

if [ -z "$ASG_SG_ID" ] || [ "$ASG_SG_ID" == "None" ]; then
    echo "❌ ASG Security Group not found: $ASG_SG_NAME"
else
    echo "✅ ASG Security Group exists: $ASG_SG_NAME ($ASG_SG_ID)"
fi

# -------------------------------
# 6️⃣ Validate DB Security Group
# -------------------------------
echo "📌 Validating DB Security Group: $DB_SG_NAME"
DB_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$DB_SG_NAME" \
    --query "SecurityGroups[0].GroupId" --output text --region $REGION)

if [ -z "$DB_SG_ID" ] || [ "$DB_SG_ID" == "None" ]; then
    echo "❌ DB Security Group not found: $DB_SG_NAME"
else
    echo "✅ DB Security Group exists: $DB_SG_NAME ($DB_SG_ID)"
fi

# -------------------------------
# 7️⃣ Validate Auto Scaling Group
# -------------------------------
echo "📌 Validating ASG: $ASG_NAME"
ASG_EXISTS=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query "AutoScalingGroups[0].AutoScalingGroupName" \
    --output text --region $REGION)

if [ -z "$ASG_EXISTS" ] || [ "$ASG_EXISTS" == "None" ]; then
    echo "❌ ASG not found: $ASG_NAME"
else
    echo "✅ ASG exists: $ASG_NAME"

    INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$ASG_NAME" \
        --query "AutoScalingGroups[0].Instances[].InstanceId" \
        --output text --region $REGION)

    if [ -z "$INSTANCE_IDS" ]; then
        echo "⚠️ No instances launched by ASG"
    else
        echo "✅ ASG Instances: $INSTANCE_IDS"
    fi
fi

# -------------------------------
# 8️⃣ Validate ASG → DB and ALB → ASG rules
# -------------------------------
if [ -n "$ASG_SG_ID" ] && [ -n "$ALB_SG_ID" ]; then
    RULE=$(aws ec2 describe-security-groups \
        --group-ids "$ASG_SG_ID" \
        --query "SecurityGroups[0].IpPermissions[?FromPort==\`5000\` && ToPort==\`5000\` && IpProtocol=='tcp' && UserIdGroupPairs[?GroupId=='$ALB_SG_ID']]" \
        --output text --region $REGION)
    if [ -n "$RULE" ]; then
        echo "✅ ALB → ASG rule exists"
    else
        echo "⚠️ ALB → ASG rule missing"
    fi
fi

if [ -n "$DB_SG_ID" ] && [ -n "$ASG_SG_ID" ]; then
    RULE=$(aws ec2 describe-security-groups \
        --group-ids "$DB_SG_ID" \
        --query "SecurityGroups[0].IpPermissions[?FromPort==\`3306\` && ToPort==\`3306\` && IpProtocol=='tcp' && UserIdGroupPairs[?GroupId=='$ASG_SG_ID']]" \
        --output text --region $REGION)
    if [ -n "$RULE" ]; then
        echo "✅ ASG → DB rule exists"
    else
        echo "⚠️ ASG → DB rule missing"
    fi
fi

# -------------------------------
# 9️⃣ Validate Frontend S3 Bucket
# -------------------------------
echo "📌 Validating frontend S3 bucket: $FRONTEND_BUCKET"
if aws s3 ls "s3://$FRONTEND_BUCKET" --region $REGION >/dev/null 2>&1; then
    echo "✅ Frontend bucket exists: $FRONTEND_BUCKET"
else
    echo "❌ Frontend bucket not found: $FRONTEND_BUCKET"
fi

# -------------------------------
# 10️⃣ Validate ALB DNS
# -------------------------------
if [ -n "$ALB_ARN" ] && [ "$ALB_ARN" != "None" ]; then
    ALB_DNS=$(aws elbv2 describe-load-balancers \
        --load-balancer-arns "$ALB_ARN" \
        --query "LoadBalancers[0].DNSName" --output text --region $REGION)
    echo "✅ ALB DNS: http://$ALB_DNS"
fi

echo "🎯 Validation completed."

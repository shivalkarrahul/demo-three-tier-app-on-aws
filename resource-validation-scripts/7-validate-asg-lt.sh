#!/bin/bash
# -------------------------------
# Variables (ensure these match your setup)
# -------------------------------
AMI_NAME="demo-app-ami"
LT_NAME="demo-app-launch-template"
ASG_NAME="demo-app-asg"
IAM_ROLE="demo-app-s3-dynamo-iam-role"
REGION="us-east-1"

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

for VAR in AMI_NAME LT_NAME ASG_NAME IAM_ROLE REGION; do
    check_var "$VAR"
done

# -------------------------------
# 1️⃣ Validate AMI
# -------------------------------
AMI_ID=$(aws ec2 describe-images \
    --filters "Name=name,Values=$AMI_NAME" \
    --query "Images[0].ImageId" --output text --region $REGION)

if [ -z "$AMI_ID" ] || [ "$AMI_ID" == "None" ]; then
    echo "❌ AMI not found: $AMI_NAME"
else
    echo "✅ AMI exists: $AMI_NAME ($AMI_ID)"
fi

# -------------------------------
# 2️⃣ Validate Launch Template
# -------------------------------
LT_EXISTS=$(aws ec2 describe-launch-templates \
    --launch-template-names "$LT_NAME" \
    --query "LaunchTemplates[0].LaunchTemplateName" --output text --region $REGION 2>/dev/null)

if [ "$LT_EXISTS" == "$LT_NAME" ]; then
    echo "✅ Launch Template exists: $LT_NAME"
else
    echo "❌ Launch Template not found: $LT_NAME"
fi

# -------------------------------
# 3️⃣ Validate Auto Scaling Group
# -------------------------------
ASG_EXISTS=$(aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-names "$ASG_NAME" \
    --query "AutoScalingGroups[0].AutoScalingGroupName" \
    --output text --region $REGION)

if [ -z "$ASG_EXISTS" ] || [ "$ASG_EXISTS" == "None" ]; then
    echo "❌ Auto Scaling Group not found: $ASG_NAME"
else
    echo "✅ Auto Scaling Group exists: $ASG_NAME"

    # Validate instances
    ASG_INSTANCE_IDS=$(aws autoscaling describe-auto-scaling-groups \
        --auto-scaling-group-names "$ASG_NAME" \
        --query "AutoScalingGroups[0].Instances[].InstanceId" \
        --output text --region $REGION)

    if [ -z "$ASG_INSTANCE_IDS" ]; then
        echo "⚠️ No instances launched by ASG $ASG_NAME"
    else
        echo "✅ Instances launched by ASG: $ASG_INSTANCE_IDS"

        # Validate IAM role attachment
        for INSTANCE in $ASG_INSTANCE_IDS; do
            ROLE_ATTACHED=$(aws ec2 describe-instances \
                --instance-ids $INSTANCE \
                --query "Reservations[0].Instances[0].IamInstanceProfile.Arn" \
                --output text --region $REGION)
            if [[ "$ROLE_ATTACHED" == *"$IAM_ROLE"* ]]; then
                echo "✅ IAM Role $IAM_ROLE attached to instance $INSTANCE"
            else
                echo "⚠️ IAM Role $IAM_ROLE NOT attached to instance $INSTANCE"
            fi
        done
    fi
fi

echo "🎯 Validation script completed."

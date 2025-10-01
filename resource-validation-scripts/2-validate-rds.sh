#!/bin/bash
set -e

echo "🔍 Validating RDS resources for demo-app..."

# Expected values
DB_SUBNET_GROUP_NAME="demo-app-db-subnet-group"
DB_SG_NAME="demo-app-db-sg"
DB_INSTANCE_ID="my-demo-db"
ENGINE="mysql"
ENGINE_VERSION="8.0.42"

# 1️⃣ Validate DB Subnet Group
echo "Checking DB Subnet Group: $DB_SUBNET_GROUP_NAME"
DB_SUBNET_GROUP=$(aws rds describe-db-subnet-groups \
    --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
    --query "DBSubnetGroups[0].DBSubnetGroupName" \
    --output text --no-cli-pager 2>/dev/null || echo "None")

if [ "$DB_SUBNET_GROUP" == "$DB_SUBNET_GROUP_NAME" ]; then
    echo "✅ DB Subnet Group exists: $DB_SUBNET_GROUP"
    SUBNET_IDS=$(aws rds describe-db-subnet-groups \
        --db-subnet-group-name $DB_SUBNET_GROUP_NAME \
        --query "DBSubnetGroups[0].Subnets[].SubnetIdentifier" \
        --output text --no-cli-pager)
    echo "   ↳ Subnets: $SUBNET_IDS"
else
    echo "❌ DB Subnet Group not found: $DB_SUBNET_GROUP_NAME"
fi

# 2️⃣ Validate Security Group
echo "Checking Security Group: $DB_SG_NAME"
DB_SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=$DB_SG_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text --no-cli-pager 2>/dev/null || echo "None")

if [ "$DB_SG_ID" != "None" ]; then
    echo "✅ Security Group exists: $DB_SG_NAME ($DB_SG_ID)"
else
    echo "❌ Security Group not found: $DB_SG_NAME"
fi

# 3️⃣ Validate RDS Instance
echo "Checking RDS Instance: $DB_INSTANCE_ID"
DB_STATE=$(aws rds describe-db-instances \
    --db-instance-identifier $DB_INSTANCE_ID \
    --query "DBInstances[0].DBInstanceStatus" \
    --output text --no-cli-pager 2>/dev/null || echo "None")

if [ "$DB_STATE" != "None" ]; then
    echo "✅ RDS Instance found: $DB_INSTANCE_ID (Status: $DB_STATE)"

    DB_ENGINE=$(aws rds describe-db-instances \
        --db-instance-identifier $DB_INSTANCE_ID \
        --query "DBInstances[0].Engine" \
        --output text --no-cli-pager)

    DB_ENGINE_VERSION=$(aws rds describe-db-instances \
        --db-instance-identifier $DB_INSTANCE_ID \
        --query "DBInstances[0].EngineVersion" \
        --output text --no-cli-pager)

    DB_SUBNET_GROUP_ATTACHED=$(aws rds describe-db-instances \
        --db-instance-identifier $DB_INSTANCE_ID \
        --query "DBInstances[0].DBSubnetGroup.DBSubnetGroupName" \
        --output text --no-cli-pager)

    DB_SG_ATTACHED=$(aws rds describe-db-instances \
        --db-instance-identifier $DB_INSTANCE_ID \
        --query "DBInstances[0].VpcSecurityGroups[].VpcSecurityGroupId" \
        --output text --no-cli-pager)

    echo "   ↳ Engine: $DB_ENGINE ($DB_ENGINE_VERSION)"
    echo "   ↳ Subnet Group: $DB_SUBNET_GROUP_ATTACHED"
    echo "   ↳ Security Groups: $DB_SG_ATTACHED"

    # Assertions
    if [ "$DB_ENGINE" == "$ENGINE" ] && [ "$DB_ENGINE_VERSION" == "$ENGINE_VERSION" ]; then
        echo "✅ Engine & Version match expected: $ENGINE $ENGINE_VERSION"
    else
        echo "⚠️ Engine/Version mismatch! Expected $ENGINE $ENGINE_VERSION"
    fi

    if [ "$DB_SUBNET_GROUP_ATTACHED" == "$DB_SUBNET_GROUP_NAME" ]; then
        echo "✅ Correct DB Subnet Group attached"
    else
        echo "⚠️ Incorrect DB Subnet Group attached"
    fi

    if [[ "$DB_SG_ATTACHED" == *"$DB_SG_ID"* ]]; then
        echo "✅ Correct Security Group attached"
    else
        echo "⚠️ Security Group mismatch"
    fi
else
    echo "❌ RDS Instance not found: $DB_INSTANCE_ID"
fi

echo "🎯 RDS validation completed."

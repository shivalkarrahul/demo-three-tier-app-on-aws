#!/bin/bash
# Validation script for DynamoDB, Lambda, and SNS resources
# Matches the style of VPC/RDS/S3 validation scripts

echo "🔹💻⚡ Validating DynamoDB, Lambda & SNS Resources..."

# -----------------------------
# 1️⃣ Validate DynamoDB Table
# -----------------------------
DDB_TABLE_NAME="demo-app-file-metadata-dynamodb"

DDB_TABLE=$(aws dynamodb describe-table \
    --table-name "$DDB_TABLE_NAME" \
    --query "Table.TableName" --output text 2>/dev/null)

if [ "$DDB_TABLE" == "$DDB_TABLE_NAME" ]; then
    echo "✅ DynamoDB Table exists: $DDB_TABLE_NAME"
else
    echo "❌ DynamoDB Table not found: $DDB_TABLE_NAME"
fi

# -----------------------------
# 2️⃣ Validate IAM Role for Lambda
# -----------------------------
ROLE_NAME="demo-app-lambda-iam-role"
ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --query "Role.Arn" --output text 2>/dev/null)

if [ -n "$ROLE_ARN" ] && [ "$ROLE_ARN" != "None" ]; then
    echo "✅ IAM Role exists: $ROLE_NAME ($ROLE_ARN)"
else
    echo "❌ IAM Role not found: $ROLE_NAME"
fi

# -----------------------------
# 3️⃣ Validate Lambda Function
# -----------------------------
LAMBDA_NAME="demo-app-metadata-lambda"
LAMBDA_ARN=$(aws lambda get-function \
    --function-name "$LAMBDA_NAME" \
    --query "Configuration.FunctionArn" --output text 2>/dev/null)

if [ -n "$LAMBDA_ARN" ] && [ "$LAMBDA_ARN" != "None" ]; then
    echo "✅ Lambda Function exists: $LAMBDA_NAME ($LAMBDA_ARN)"
else
    echo "❌ Lambda Function not found: $LAMBDA_NAME"
fi

# -----------------------------
# 4️⃣ Validate SNS Topic & Subscription
# -----------------------------
SNS_TOPIC_NAME="demo-app-sns-topic"
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn,'$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)

if [ -n "$SNS_TOPIC_ARN" ] && [ "$SNS_TOPIC_ARN" != "None" ]; then
    echo "✅ SNS Topic exists: $SNS_TOPIC_NAME ($SNS_TOPIC_ARN)"

    SUBSCRIPTION_ARN=$(aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPIC_ARN" \
        --query "Subscriptions[?Endpoint=='$LAMBDA_ARN'].SubscriptionArn" --output text)

    if [ -n "$SUBSCRIPTION_ARN" ] && [ "$SUBSCRIPTION_ARN" != "None" ]; then
        echo "✅ Lambda is subscribed to SNS Topic: $SUBSCRIPTION_ARN"
    else
        echo "❌ Lambda not subscribed to SNS Topic: $SNS_TOPIC_NAME"
    fi
else
    echo "❌ SNS Topic not found: $SNS_TOPIC_NAME"
fi

echo "🔹💻⚡ Validation completed."

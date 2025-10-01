#!/bin/bash
# 4-validate-sns.sh
# Validation script for SNS topic and S3 notification

SNS_TOPIC_NAME="demo-app-sns-topic"
S3_BUCKET_NAME="demo-app-backend-s3-bucket-12345"
EMAIL="your-email@example.com"
EVENT_NAME="demo-app-s3-object-upload-notification"

echo "🔹💻⚡ Validating SNS Topic: $SNS_TOPIC_NAME"

# Check if SNS Topic exists
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)

if [ "$SNS_TOPIC_ARN" != "None" ] && [ -n "$SNS_TOPIC_ARN" ]; then
    echo "✅ SNS Topic exists: $SNS_TOPIC_ARN"

    # Check email subscription
    SUBSCRIPTION_ARN=$(aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPIC_ARN" \
        --query "Subscriptions[?Endpoint=='$EMAIL'].SubscriptionArn" --output text)
    
    if [ "$SUBSCRIPTION_ARN" != "None" ] && [ -n "$SUBSCRIPTION_ARN" ]; then
        echo "⚠️ Email subscription exists but may need confirmation: $EMAIL"
    else
        echo "❌ Email not subscribed: $EMAIL"
    fi

    # Check Topic Policy contains S3 publish permission
    POLICY=$(aws sns get-topic-attributes --topic-arn "$SNS_TOPIC_ARN" --query "Attributes.Policy" --output text)

    # Use jq to parse
    if echo "$POLICY" | jq -e '.Statement[] | select(.Principal.Service=="s3.amazonaws.com")' >/dev/null; then
        echo "✅ SNS Topic policy allows S3 to publish"
    else
        echo "❌ SNS Topic policy does NOT allow S3 to publish"
    fi

    # Check S3 bucket notification
    NOTIF=$(aws s3api get-bucket-notification-configuration --bucket "$S3_BUCKET_NAME")
    if echo "$NOTIF" | grep -q "$SNS_TOPIC_ARN"; then
        echo "✅ S3 Bucket $S3_BUCKET_NAME is configured to send notifications to SNS Topic"
    else
        echo "❌ S3 Bucket $S3_BUCKET_NAME is NOT configured to send notifications to SNS Topic"
    fi

else
    echo "❌ SNS Topic not found: $SNS_TOPIC_NAME"
fi

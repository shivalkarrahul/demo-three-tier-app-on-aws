#!/bin/bash
# 4-validate-sns.sh
# Validation script for SNS topic and S3 notification

SNS_TOPIC_NAME="demo-app-sns-topic"
BACKEND_BUCKET_NAME="$BACKEND_BUCKET_NAME"
EVENT_NAME="demo-app-s3-object-upload-notification"

echo "🔹💻⚡ Validating SNS Topic: $SNS_TOPIC_NAME"

# Check if SNS Topic exists
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, '$SNS_TOPIC_NAME')].TopicArn | [0]" --output text)

if [ "$SNS_TOPIC_ARN" != "None" ] && [ -n "$SNS_TOPIC_ARN" ]; then
    echo "✅ SNS Topic exists: $SNS_TOPIC_ARN"

    # Fetch all subscriptions for the topic
    SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPIC_ARN" --output json)

    # Loop through all subscriptions using process substitution
    while read -r sub; do
        ENDPOINT=$(echo "$sub" | jq -r '.Endpoint')
        PROTOCOL=$(echo "$sub" | jq -r '.Protocol')
        SUB_ARN=$(echo "$sub" | jq -r '.SubscriptionArn')

        case "$SUB_ARN" in
            "PendingConfirmation")
                STATUS_MSG="⚠️ Subscription pending confirmation, go to the Inbox and click on Confirm subscription"
                ;;
            "Deleted")
                STATUS_MSG="❌ Subscription deleted"
                ;;
            *)
                STATUS_MSG="✅ Subscription confirmed"
                ;;
        esac

        echo "$STATUS_MSG: $ENDPOINT ($PROTOCOL, $SUB_ARN)"
    done < <(echo "$SUBSCRIPTIONS" | jq -c '.Subscriptions[]')

    # Check Topic Policy contains S3 publish permission
    POLICY=$(aws sns get-topic-attributes --topic-arn "$SNS_TOPIC_ARN" --query "Attributes.Policy" --output text)

    if echo "$POLICY" | jq -e '.Statement[] | select(.Principal.Service=="s3.amazonaws.com")' >/dev/null; then
        echo "✅ SNS Topic policy allows S3 to publish"
    else
        echo "❌ SNS Topic policy does NOT allow S3 to publish"
    fi

    # Check S3 bucket notification
    NOTIF=$(aws s3api get-bucket-notification-configuration --bucket "$BACKEND_BUCKET_NAME")
    if echo "$NOTIF" | grep -q "$SNS_TOPIC_ARN"; then
        echo "✅ S3 Bucket $BACKEND_BUCKET_NAME is configured to send notifications to SNS Topic"
    else
        echo "❌ S3 Bucket $BACKEND_BUCKET_NAME is NOT configured to send notifications to SNS Topic"
    fi

else
    echo "❌ SNS Topic not found: $SNS_TOPIC_NAME"
fi

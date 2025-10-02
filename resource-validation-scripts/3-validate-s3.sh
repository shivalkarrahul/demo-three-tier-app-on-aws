#!/bin/bash
# 3-validate-s3.sh
# Validation script for S3 bucket

BACKEND_BUCKET_NAME=$BACKEND_BUCKET_NAME
REGION="us-east-1"

echo "🔹💻⚡ Validating S3 Bucket: $BACKEND_BUCKET_NAME in region $REGION"

# Check if bucket exists
if aws s3api head-bucket --bucket "$BACKEND_BUCKET_NAME" 2>/dev/null; then
    echo "✅ S3 Bucket exists: $BACKEND_BUCKET_NAME"

    # Optional: check bucket region
    BUCKET_REGION=$(aws s3api get-bucket-location --bucket "$BACKEND_BUCKET_NAME" --query "LocationConstraint" --output text)
    # us-east-1 returns None
    if [ "$BUCKET_REGION" == "None" ]; then
        BUCKET_REGION="us-east-1"
    fi

    if [ "$BUCKET_REGION" == "$REGION" ]; then
        echo "✅ Bucket region matches expected region: $REGION"
    else
        echo "⚠️ Bucket region mismatch. Expected: $REGION, Found: $BUCKET_REGION"
    fi
else
    echo "❌ S3 Bucket not found: $BACKEND_BUCKET_NAME"
fi

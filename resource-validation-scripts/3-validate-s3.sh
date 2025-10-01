#!/bin/bash
# 3-validate-s3.sh
# Validation script for S3 bucket

BUCKET_NAME="demo-app-backend-s3-bucket-12345"
REGION="us-east-1"

echo "🔹💻⚡ Validating S3 Bucket: $BUCKET_NAME in region $REGION"

# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✅ S3 Bucket exists: $BUCKET_NAME"

    # Optional: check bucket region
    BUCKET_REGION=$(aws s3api get-bucket-location --bucket "$BUCKET_NAME" --query "LocationConstraint" --output text)
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
    echo "❌ S3 Bucket not found: $BUCKET_NAME"
fi

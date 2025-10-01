#!/bin/bash

# ===========================
# VPC Validation Script
# ===========================

VPC_NAME="demo-app-vpc"
IGW_NAME="demo-app-igw"
PUB_RT_NAME="demo-app-public-rt"
PRI_RT_NAME="demo-app-private-rt-1"
NAT_NAME="demo-app-nat-gateway-1"
EIP_NAME="demo-app-eip-1"

# ---------------------------
# 1️⃣ Check VPC
# ---------------------------
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query "Vpcs[0].VpcId" --output text --no-cli-pager)

if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
    echo "✅ VPC exists: $VPC_NAME ($VPC_ID)"
else
    echo "❌ VPC not found: $VPC_NAME"
    #exit 1
fi

# ---------------------------
# 2️⃣ Check Subnets
# ---------------------------
declare -A PUBLIC_SUBNETS=( ["demo-app-public-subnet-1"]="10.0.1.0/24" ["demo-app-public-subnet-2"]="10.0.2.0/24" ["demo-app-public-subnet-3"]="10.0.3.0/24" )
declare -A PRIVATE_SUBNETS=( ["demo-app-private-subnet-1"]="10.0.11.0/24" ["demo-app-private-subnet-2"]="10.0.12.0/24" ["demo-app-private-subnet-3"]="10.0.13.0/24" )


echo ""
echo "🔹 Checking Public Subnets..."
for name in "${!PUBLIC_SUBNETS[@]}"; do
    SUBNET_INFO=$(aws ec2 describe-subnets \
        --filters "Name=tag:Name,Values=$name" "Name=vpc-id,Values=$VPC_ID" \
        --query "Subnets[0].[SubnetId,CidrBlock]" --output text --no-cli-pager)
    
    SUBNET_ID=$(echo "$SUBNET_INFO" | awk '{print $1}')
    CIDR=$(echo "$SUBNET_INFO" | awk '{print $2}')

    if [ -n "$SUBNET_ID" ] && [ "$SUBNET_ID" != "None" ]; then
        if [ "$CIDR" == "${PUBLIC_SUBNETS[$name]}" ]; then
            echo "✅ Public Subnet exists with correct CIDR: $name ($SUBNET_ID, $CIDR)"
        else
            echo "❌ Public Subnet exists but CIDR mismatch: $name ($SUBNET_ID, $CIDR) expected ${PUBLIC_SUBNETS[$name]}"
        fi
    else
        echo "❌ Public Subnet not found: $name"
    fi
done

echo ""
echo "🔹 Checking Private Subnets..."
for name in "${!PRIVATE_SUBNETS[@]}"; do
    SUBNET_INFO=$(aws ec2 describe-subnets \
        --filters "Name=tag:Name,Values=$name" "Name=vpc-id,Values=$VPC_ID" \
        --query "Subnets[0].[SubnetId,CidrBlock]" --output text --no-cli-pager)
    
    SUBNET_ID=$(echo "$SUBNET_INFO" | awk '{print $1}')
    CIDR=$(echo "$SUBNET_INFO" | awk '{print $2}')

    if [ -n "$SUBNET_ID" ] && [ "$SUBNET_ID" != "None" ]; then
        if [ "$CIDR" == "${PRIVATE_SUBNETS[$name]}" ]; then
            echo "✅ Private Subnet exists with correct CIDR: $name ($SUBNET_ID, $CIDR)"
        else
            echo "❌ Private Subnet exists but CIDR mismatch: $name ($SUBNET_ID, $CIDR) expected ${PRIVATE_SUBNETS[$name]}"
        fi
    else
        echo "❌ Private Subnet not found: $name"
    fi
done


# ---------------------------
# 3️⃣ Check Internet Gateway
# ---------------------------
IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=$IGW_NAME" \
    --query "InternetGateways[0].InternetGatewayId" --output text --no-cli-pager)

if [ -n "$IGW_ID" ] && [ "$IGW_ID" != "None" ]; then
    ATTACHED_VPC=$(aws ec2 describe-internet-gateways \
        --internet-gateway-ids "$IGW_ID" \
        --query "InternetGateways[0].Attachments[0].VpcId" --output text --no-cli-pager)
    if [ "$ATTACHED_VPC" == "$VPC_ID" ]; then
        echo "✅ Internet Gateway exists and attached: $IGW_NAME ($IGW_ID)"
    else
        echo "❌ Internet Gateway exists but not attached to $VPC_NAME"
    fi
else
    echo "❌ Internet Gateway not found: $IGW_NAME"
fi

# ---------------------------
# 4️⃣ Check Public Route Table
# ---------------------------
PUB_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=$PUB_RT_NAME" "Name=vpc-id,Values=$VPC_ID" \
    --query "RouteTables[0].RouteTableId" --output text --no-cli-pager)

if [ -n "$PUB_RT_ID" ] && [ "$PUB_RT_ID" != "None" ]; then
    ROUTE_TARGET=$(aws ec2 describe-route-tables \
        --route-table-ids "$PUB_RT_ID" \
        --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'].GatewayId | [0]" --output text --no-cli-pager)
    if [ "$ROUTE_TARGET" == "$IGW_ID" ]; then
        echo "✅ Public Route Table exists and routes to IGW: $PUB_RT_NAME ($PUB_RT_ID)"
    else
        echo "❌ Public Route Table $PUB_RT_NAME exists but route misconfigured"
    fi

    # Check subnet associations
    echo "Checking Public Route Table subnet associations..."
    for subnet in "${!PUBLIC_SUBNETS[@]}"; do
        SUBNET_ID=$(aws ec2 describe-subnets \
            --filters "Name=tag:Name,Values=$subnet" "Name=vpc-id,Values=$VPC_ID" \
            --query "Subnets[0].SubnetId" --output text --no-cli-pager)
        ASSOCIATED=$(aws ec2 describe-route-tables --route-table-ids "$PUB_RT_ID" \
            --query "RouteTables[0].Associations[?SubnetId=='$SUBNET_ID'].SubnetId | [0]" --output text --no-cli-pager)
        if [ "$ASSOCIATED" == "$SUBNET_ID" ]; then
            echo "✅ $subnet associated with Public RT"
        else
            echo "❌ $subnet not associated with Public RT"
        fi
    done
else
    echo "❌ Public Route Table not found: $PUB_RT_NAME"
fi

# ---------------------------
# 5️⃣ Check NAT Gateway
# ---------------------------


NAT_ID=$(aws ec2 describe-nat-gateways \
    --filter "Name=tag:Name,Values=$NAT_NAME" \
    --query "NatGateways[0].NatGatewayId" --output text --no-cli-pager)

if [ -n "$NAT_ID" ] && [ "$NAT_ID" != "None" ]; then
    NAT_STATE=$(aws ec2 describe-nat-gateways --nat-gateway-ids "$NAT_ID" \
        --query "NatGateways[0].State" --output text --no-cli-pager)
    if [ "$NAT_STATE" == "available" ]; then
        echo "✅ NAT Gateway exists and available: $NAT_NAME ($NAT_ID)"
    else
        echo "❌ NAT Gateway exists but not available: $NAT_STATE"
    fi
else
    echo "❌ NAT Gateway not found: $NAT_NAME"
fi

echo ""
echo "🔹 Checking Elastic IPs..."
for name in "${!EIPS[@]}"; do
    EIP_INFO=$(aws ec2 describe-addresses \
        --filters "Name=tag:Name,Values=$name" \
        --query "Addresses[0].[AllocationId,PublicIp]" --output text --no-cli-pager)
    
    ALLOCATION_ID=$(echo "$EIP_INFO" | awk '{print $1}')
    PUBLIC_IP=$(echo "$EIP_INFO" | awk '{print $2}')

    if [ -n "$ALLOCATION_ID" ] && [ "$ALLOCATION_ID" != "None" ]; then
        echo "✅ Elastic IP exists: $name ($PUBLIC_IP, $ALLOCATION_ID)"
    else
        echo "❌ Elastic IP not found: $name"
    fi
done


# ---------------------------
# 6️⃣ Check Private Route Table
# ---------------------------
PRI_RT_ID=$(aws ec2 describe-route-tables \
    --filters "Name=tag:Name,Values=$PRI_RT_NAME" "Name=vpc-id,Values=$VPC_ID" \
    --query "RouteTables[0].RouteTableId" --output text --no-cli-pager)

if [ -n "$PRI_RT_ID" ] && [ "$PRI_RT_ID" != "None" ]; then
    ROUTE_TARGET=$(aws ec2 describe-route-tables \
        --route-table-ids "$PRI_RT_ID" \
        --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'].NatGatewayId | [0]" --output text --no-cli-pager)
    if [ "$ROUTE_TARGET" == "$NAT_ID" ]; then
        echo "✅ Private Route Table exists and routes to NAT: $PRI_RT_NAME ($PRI_RT_ID)"
    else
        echo "❌ Private Route Table $PRI_RT_NAME exists but route misconfigured"
    fi

    # Check subnet associations
    echo "Checking Private Route Table subnet associations..."
    for subnet in "${!PRIVATE_SUBNETS[@]}"; do
        SUBNET_ID=$(aws ec2 describe-subnets \
            --filters "Name=tag:Name,Values=$subnet" "Name=vpc-id,Values=$VPC_ID" \
            --query "Subnets[0].SubnetId" --output text --no-cli-pager)
        ASSOCIATED=$(aws ec2 describe-route-tables --route-table-ids "$PRI_RT_ID" \
            --query "RouteTables[0].Associations[?SubnetId=='$SUBNET_ID'].SubnetId | [0]" --output text --no-cli-pager)
        if [ "$ASSOCIATED" == "$SUBNET_ID" ]; then
            echo "✅ $subnet associated with Private RT"
        else
            echo "❌ $subnet not associated with Private RT"
        fi
    done
else
    echo "❌ Private Route Table not found: $PRI_RT_NAME"
fi

echo ""
echo "🎉 VPC Validation Completed!"
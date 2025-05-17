#!/bin/bash

# === Config ===
DOMAIN="devopssaif.online"
CALLER_REF=$(date +%s)

# === Step 1: Create Hosted Zone ===
echo "Creating hosted zone for domain: $DOMAIN"

CREATE_OUTPUT=$(aws route53 create-hosted-zone \
  --name "$DOMAIN" \
  --caller-reference "$CALLER_REF" \
  --hosted-zone-config Comment="Managed by CLI",PrivateZone=false)

echo "✅ Hosted zone created."

# === Step 2: Extract Hosted Zone ID and NS records ===
HOSTED_ZONE_ID=$(echo "$CREATE_OUTPUT" | jq -r '.HostedZone.Id' | sed 's|/hostedzone/||')

echo "🔍 Hosted Zone ID: $HOSTED_ZONE_ID"

echo "Fetching NS records for domain..."
NS_RECORDS=$(aws route53 list-resource-record-sets \
  --hosted-zone-id "$HOSTED_ZONE_ID" \
  --query "ResourceRecordSets[?Type == 'NS'].[ResourceRecords[*].Value]" \
  --output text)

echo ""
echo "========================================"
echo "👉 Copy the following nameservers and add them to BigRock:"
echo "========================================"

echo "$NS_RECORDS" | tr '\t' '\n'

echo "========================================"
echo "⏳ It may take a few minutes to propagate."
echo ""
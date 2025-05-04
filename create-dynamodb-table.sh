#!/bin/bash

# Default values
TABLE_NAME=my-table
REGION=ap-south-1

echo "🔧 Creating DynamoDB table: $TABLE_NAME in region $REGION..."

# Create the table
aws dynamodb create-table   --table-name "$TABLE_NAME"   --attribute-definitions AttributeName=id,AttributeType=S   --key-schema AttributeName=id,KeyType=HASH   --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5   --region "$REGION"

# Wait until the table is active
echo "⏳ Waiting for table to be active..."
aws dynamodb wait table-exists   --table-name "$TABLE_NAME"   --region "$REGION"

echo "✅ Table '$TABLE_NAME' created and ready."

# Insert test data into DynamoDB table
echo "🔧 Inserting test data into $TABLE_NAME..."

aws dynamodb put-item   --table-name "$TABLE_NAME"   --item '{"id": {"S": "1"}, "name": {"S": "Test Item 1"}, "description": {"S": "This is the first test item."}}'   --region "$REGION"

aws dynamodb put-item   --table-name "$TABLE_NAME"   --item '{"id": {"S": "2"}, "name": {"S": "Test Item 2"}, "description": {"S": "This is the second test item."}}'   --region "$REGION"

aws dynamodb put-item   --table-name "$TABLE_NAME"   --item '{"id": {"S": "3"}, "name": {"S": "Test Item 3"}, "description": {"S": "This is the third test item."}}'   --region "$REGION"

echo "✅ Test data inserted successfully into $TABLE_NAME."

#!/bin/bash

# Variables
APP_DIR="backend-app"
PORT=8080
REGION="ap-south-1"
TABLE_NAME="my-table"

# Step 1: Create project directory
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Step 2: Initialize Node.js project
npm init -y

# Step 3: Set module type for ES modules
jq '. + {type: "module"}' package.json > temp.json && mv temp.json package.json

# Step 4: Install dependencies
npm install express aws-sdk cors

# Step 5: Create app.js
cat <<EOF > app.js
import express from 'express';
import AWS from 'aws-sdk';
import cors from 'cors';

const app = express();
const port = ${PORT};

// Enable CORS
app.use(cors());

// AWS Config
AWS.config.update({
  region: '${REGION}'
});

const dynamoDB = new AWS.DynamoDB.DocumentClient();

app.get('/testdb', async (req, res) => {
  try {
    const data = await dynamoDB.scan({ TableName: '${TABLE_NAME}' }).promise();
    res.json({ success: true, data });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to fetch data from DynamoDB' });
  }
});

app.listen(port, () => {
  console.log(\`✅ Backend app running on port \${port}\`);
});
EOF

# Step 6: Done
echo "✅ Backend app created in ./$APP_DIR"
echo "👉 To start the app, run: cd $APP_DIR && node app.js"

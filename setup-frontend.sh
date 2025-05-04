#!/bin/bash

# Set defaults
FRONTEND_DIR="frontend-app"
PORT=3000

# Get backend IP dynamically (assumes backend running on same EC2 instance)
BACKEND_IP=$(curl -s ifconfig.me)
BACKEND_URL="http://${BACKEND_IP}:8080"

echo "🌐 Detected backend IP: $BACKEND_IP"
echo "📁 Creating frontend in ./$FRONTEND_DIR"

# Remove old folder if exists
rm -rf $FRONTEND_DIR

# Create frontend directory
mkdir -p $FRONTEND_DIR

# Create package.json so npx can work in this folder
cat > $FRONTEND_DIR/package.json <<EOF
{
  "name": "frontend-app",
  "version": "1.0.0",
  "description": "Simple frontend for backend test",
  "scripts": {
    "start": "http-server -p $PORT"
  },
  "dependencies": {}
}
EOF

# Create index.html
cat > $FRONTEND_DIR/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>Frontend App</title>
</head>
<body>
  <h1>📊 Load Data from Backend</h1>
  <button onclick="loadData()">Load Data</button>
  <pre id="output"></pre>

  <script>
    async function loadData() {
      try {
        const response = await fetch('${BACKEND_URL}/testdb');
        const result = await response.json();
        document.getElementById('output').textContent = JSON.stringify(result, null, 2);
      } catch (error) {
        console.error('❌ Error:', error);
        alert('Error fetching data from the backend!');
      }
    }
  </script>
</body>
</html>
EOF

# Move into frontend directory
cd $FRONTEND_DIR

# Install http-server locally
echo "📦 Installing http-server locally..."
npm install http-server --save-dev

# Start the frontend using local install
echo "🚀 Starting frontend at http://localhost:$PORT"
npx http-server -p $PORT

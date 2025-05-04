Setting up **`kubectl`**, **`eksctl`**, **Docker**, and **Docker Compose** on an **Amazon Linux EC2 instance**:

---

# 🚀 AWS EC2 Setup for EKS and Docker

This guide sets up an Amazon Linux EC2 instance with:

* `kubectl` – for interacting with Kubernetes clusters
* `eksctl` – for creating and managing EKS clusters
* `Docker` – for container operations
* `Docker Compose` – for defining and running multi-container apps

---

## 🖥️ Prerequisites

* An EC2 instance running **Amazon Linux 2**
* Access to the instance via SSH (`ec2-user`)

---

## ✅ Step 1: Install `kubectl`

```bash
# Download kubectl binary for EKS (v1.32.0)
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.32.0/2024-12-20/bin/linux/amd64/kubectl

# Make it executable
chmod +x ./kubectl

# Move to user's bin and update PATH
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
export PATH=$HOME/bin:$PATH
```

---

## ✅ Step 2: Install `eksctl`

```bash
# Set platform details
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

# Download eksctl binary
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

# Extract and move binary
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz
sudo mv /tmp/eksctl /usr/local/bin
```

---

## ✅ Step 2.1: Create cluster

First Copy the Key in bastion sever 
```
ls -l K8s.pem
scp -i K8s.pem K8s.pem ec2-user@13.233.9.127:/home/ec2-user/
```
on bastion host
```
eksctl create cluster -f cluster.yaml
```
---

## ✅ Step 3: Install Docker

```bash
# Update packages
sudo yum update -y

# Install Docker
sudo yum install -y docker

# Start Docker service
sudo service docker start

# Add ec2-user to Docker group
sudo usermod -a -G docker ec2-user
```

> 🔄 we may need to **log out and log back in** or run `newgrp docker` to apply group changes.

---

## ✅ Step 4: Install Docker Compose

```bash
# Download Docker Compose binary
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose

# Make it executable
sudo chmod +x /usr/local/bin/docker-compose
```

---

## ✅ Final Checks

Verify installations:

```bash
kubectl version --client
eksctl version
docker version
docker-compose version
```

---

## 🏁 we're Ready!

we now have a fully configured environment for:

* Managing **EKS clusters** with `eksctl`
* Interacting with Kubernetes using `kubectl`
* Building and running **Dockerized apps** using `Docker` and `Docker Compose`

---



Great! Since we've now set up wer EC2 instance with `kubectl`, `eksctl`, Docker, and Docker Compose, let's walk through the **3-tier application** we built and deployed.

Here’s a professional, **beautifully structured documentation** for wer **Dockerized Full-Stack App** (Node.js backend + HTML/JS frontend + DynamoDB), designed for deployment on an EC2 instance.

---

# 🚀 Full-Stack Dockerized App with Node.js, HTML Frontend & DynamoDB (AWS)

## 📦 Overview

This project is a lightweight, containerized full-stack application with:

* **Backend**: Node.js + Express REST API
* **Frontend**: Static HTML + JavaScript (calls backend API)
* **Database**: AWS DynamoDB
* **Deployment**: Docker Compose on EC2
* **Bonus**: Dynamically configured frontend using backend’s private IP

---

## 🧱 Architecture

```
┌────────────┐         ┌─────────────┐        ┌────────────┐
│  Frontend  │ ─────▶  │  Backend     │ ─────▶ │ DynamoDB   │
│ (http-server)        │ (Node.js API)│        │ (AWS-hosted)│
└────────────┘         └─────────────┘        └────────────┘
```

---

## 🌐 Backend API

**Tech Stack**: Node.js, Express, AWS SDK

### Endpoints:

* `GET /data` → Returns all items from DynamoDB `my-table`.

### Folder Structure:

```
backend-app/
├── app.js
├── package.json
└── insert-data.js (prepopulates DynamoDB)
```

---

## 🎨 Frontend

**Tech Stack**: Static HTML + JS + http-server

### Features:

* Button to fetch and display data from backend
* Automatically uses EC2 internal IP to call backend

### Folder Structure:

```
frontend-app/
├── index.html
├── script.js
└── dynamic-ip-inject.sh (injects EC2 IP into script.js)
```

---

## 🐳 Dockerized Setup

**Docker Compose File**:

```yaml
services:
  backend:
    build: ./backend-app
    ports:
      - "5000:5000"
    environment:
      - AWS_REGION=ap-south-1

  frontend:
    build: ./frontend-app
    ports:
      - "3000:3000"
```

### ✅ How to Run

```bash
docker-compose up --build
```

---

## ⚙️ AWS DynamoDB Table

**Table Name**: `my-table`
**Partition Key**: `id` (String)

### Sample Data Inserted:

| id | name        | description                  |
| -- | ----------- | ---------------------------- |
| 1  | Test Item 1 | This is the first test item  |
| 2  | Test Item 2 | This is the second test item |
| 3  | Test Item 3 | This is the third test item  |

---

## 📦 Dockerfile Optimizations

Images are based on:

* Backend: `node:18-alpine`
* Frontend: `node:18-alpine` with `http-server`

**Result**: Image size is < 150MB each

---

## 🛠️ Pre-Requisites

* AWS CLI configured with DynamoDB access
* Docker & Docker Compose installed
* Node.js installed on EC2 (for initial script setup)

---

## 🧪 Verifying

Once both containers are running:

1. Access `http://<EC2-IP>:3000` in wer browser.
2. Click **"Load Data"**
3. ✅ Should see 3 items from DynamoDB rendered.

---

## 🔐 Security Tips

* Don't push secrets or tokens to GitHub!
* Use `.env` and AWS Secrets Manager
* Enable CORS only where required

---

## 📝 Future Improvements

* Add login/auth (Cognito or JWT)
* Frontend framework (React/Vue)
* Backend validation & logging
* CI/CD with GitHub Actions & ECR push


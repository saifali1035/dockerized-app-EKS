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

> 🔄 You may need to **log out and log back in** or run `newgrp docker` to apply group changes.

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

## 🏁 You're Ready!

You now have a fully configured environment for:

* Managing **EKS clusters** with `eksctl`
* Interacting with Kubernetes using `kubectl`
* Building and running **Dockerized apps** using `Docker` and `Docker Compose`

---



Great! Since you've now set up your EC2 instance with `kubectl`, `eksctl`, Docker, and Docker Compose, let's walk through the **3-tier application** you built and deployed.

---

## 🧱 What is a 3-Tier Architecture?

A **3-tier architecture** is a commonly used software architecture pattern that separates concerns into three distinct layers:

| Tier         | Role                                                       |
| ------------ | ---------------------------------------------------------- |
| **Frontend** | User interface (UI) that interacts with users              |
| **Backend**  | Handles business logic and API endpoints                   |
| **Database** | Stores and retrieves application data (persistent storage) |

---

## ✅ Components of Your 3-Tier Application

You implemented this architecture using:

### 1. **Frontend**

* **Technology**: HTML/JavaScript (or React if used)
* **Tool**: `http-server` (or served via NGINX in Docker)
* **Purpose**: Renders UI in a browser and makes API calls to the backend

### 2. **Backend**

* **Technology**: Node.js (Express.js)
* **Functionality**:

  * Defines API endpoints (e.g., `/api/data`)
  * Connects to the database
  * Implements business logic

### 3. **Database**

* **Technology**: MongoDB
* **Usage**:

  * Stores application data
  * Backend interacts with this to read/write data

---

## 🔁 How the App Works (Flow)

1. **User opens the app** in a browser via the frontend URL.
2. **Frontend makes API requests** (e.g., `GET /api/data`) to the backend.
3. **Backend receives the request**, processes it, and interacts with MongoDB.
4. **Backend sends response** back to the frontend.
5. **Frontend displays** the data to the user.

---

## 🐳 Dockerization Overview

You containerized the app using Docker. Here's how:

* **Frontend Dockerfile**:

  * Builds static files
  * Uses `http-server` or NGINX to serve them

* **Backend Dockerfile**:

  * Installs Node.js dependencies
  * Runs Express server

* **MongoDB**:

  * Pulled as an official image from Docker Hub

* **Docker Compose**:

  * Defined services (`frontend`, `backend`, `mongo`)
  * Enabled easy orchestration with network bridging

---

## 📦 Docker Compose Sample (Recap)

```yaml
version: '3'
services:
  mongo:
    image: mongo
    container_name: mongo-db
    ports:
      - "27017:27017"
    volumes:
      - mongo-data:/data/db

  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - MONGO_URL=mongodb://mongo-db:27017/appdb
    depends_on:
      - mongo

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    depends_on:
      - backend

volumes:
  mongo-data:
```

---

## 🧪 How to Test

* Visit `http://<EC2_PUBLIC_IP>:3000` – You should see the frontend.
* Click a button like “Load Data” – Should fetch and display data from the backend.
* Backend fetches data from MongoDB – proves end-to-end communication.

---



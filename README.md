Here's a clean and well-formatted document you can use for setting up **`kubectl`**, **`eksctl`**, **Docker**, and **Docker Compose** on an **Amazon Linux EC2 instance**:

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


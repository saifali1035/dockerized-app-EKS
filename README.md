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
---
## ✅ Step 5: Create ECR Repos to hold our build images.

```
sh ecr_repo_create.sh
```

---
## ✅ Step 5: Integrate our CI using GitHub Workflow.

Create following secrets in your repo 
* AWS_REGION
* AWS_ACCOUNT_ID
* AWS_ACCESS_KEY_ID
* AWS_SECRET_ACCESS_KEY
* HELM_REPO_TOKEN - Github token

<img width="1154" alt="image" src="https://github.com/user-attachments/assets/f581c63c-889f-43ea-91c0-3af4fe1c48a0" />


```
name: EKS Deployment

on:
  push:
    branches: [ master ]
    paths:
      - 'frontend-app/**'
      - 'backend-app/**'
      - '.github/workflows/**'

env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
  FRONTEND_REPO: frontend-app
  BACKEND_REPO: backend-app

jobs:
  build-backend:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Build backend Docker image
        run: |
          cd backend-app
          docker build -t $BACKEND_REPO:latest .
          docker save $BACKEND_REPO:latest -o backend.tar

      - name: Upload backend image
        uses: actions/upload-artifact@v4
        with:
          name: backend-image
          path: backend-app/backend.tar

  build-frontend:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Extract version from package.json
        id: extract_version
        run: |
          VERSION=$(jq -r .version frontend-app/package.json)
          echo "$VERSION" > version.txt

      - name: Upload version file
        uses: actions/upload-artifact@v4
        with:
          name: version
          path: version.txt

      - name: Build frontend Docker image
        run: |
          cd frontend-app
          docker build -t $FRONTEND_REPO:latest .
          docker save $FRONTEND_REPO:latest -o frontend.tar

      - name: Upload frontend image
        uses: actions/upload-artifact@v4
        with:
          name: frontend-image
          path: frontend-app/frontend.tar

  push-images:
    needs: [build-frontend, build-backend]
    runs-on: ubuntu-latest
    steps:
      - name: Download frontend artifact
        uses: actions/download-artifact@v4
        with:
          name: frontend-image
          path: .

      - name: Download backend artifact
        uses: actions/download-artifact@v4
        with:
          name: backend-image
          path: .

      - name: Download version file
        uses: actions/download-artifact@v4
        with:
          name: version
          path: .

      - name: Read version from file
        run: |
          VERSION=$(cat version.txt)
          echo "VERSION=$VERSION" >> $GITHUB_ENV

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Login to Amazon ECR
        run: |
          aws ecr get-login-password --region $AWS_REGION | \
          docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

      - name: Tag and push backend image with version
        run: |
          docker load -i backend.tar
          docker tag $BACKEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$VERSION
          docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_REPO:$VERSION

      - name: Tag and push frontend image with version
        run: |
          docker load -i frontend.tar
          docker tag $FRONTEND_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$VERSION
          docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_REPO:$VERSION

  manual-approval:
    needs: push-images
    runs-on: ubuntu-latest
    environment:
      name: helm-approval
    steps:
      - name: Wait for manual approval
        run: echo "Awaiting manual approval before updating Helm chart."

  update-helm-chart:
    needs: manual-approval
    runs-on: ubuntu-latest
    steps:
      - name: Download version file
        uses: actions/download-artifact@v4
        with:
          name: version
          path: .

      - name: Read version from file
        run: |
          VERSION=$(cat version.txt)
          echo "VERSION=$VERSION" >> $GITHUB_ENV

      - name: Clone Helm Chart Repo
        run: |
          git config --global user.email "ci-bot@yourcompany.com"
          git config --global user.name "CI Bot"

          git clone https://x-access-token:${{ secrets.HELM_REPO_TOKEN }}@github.com/saifali1035/eks-app-helm-chart.git
          cd eks-app-helm-chart

          # Ensure we have all branches locally
          git fetch origin
          git checkout master
          git pull origin master

          BRANCH="update-images-$VERSION"
          git checkout -b $BRANCH

          # Update tag
          sed -i "s/tag: \".*\"/tag: \"$VERSION\"/" dockerized-app/values.yaml


          # Check if there are any changes
          if git diff --quiet; then
            echo "No changes to commit."
            exit 0
          fi

          git add .
          git commit -m "Update frontend and backend image tags to $VERSION"
          git push origin $BRANCH

          gh pr create --title "Update image tags to $VERSION" \
                       --body "Auto-update of Helm charts for version $VERSION" \
                       --base master \
                       --head $BRANCH \
                       --repo saifali1035/eks-app-helm-chart
        env:
          GITHUB_TOKEN: ${{ secrets.HELM_REPO_TOKEN }}
```

This GitHub Actions workflow automates the **build, versioning, push, and deployment process** for a Dockerized 3-tier application (React frontend + Node.js backend) deployed on Amazon EKS using **Helm charts**.

**Workflow Name:** `EKS Deployment`
**Triggers:**

* On push to the `master` branch
* When any of these paths change:

  * `frontend-app/**`
  * `backend-app/**`
  * `.github/workflows/**`

**Goals:**

* Build Docker images for frontend and backend
* Tag them using the frontend version (from `package.json`)
* Push them to Amazon ECR
* Create a PR to update the Helm chart with the new version tags
* Await manual approval before Helm PR is created

---

## 📂 **Environment Variables**

```yaml
env:
  AWS_REGION: ${{ secrets.AWS_REGION }}
  AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
  FRONTEND_REPO: frontend-app
  BACKEND_REPO: backend-app
```

These are global environment variables used in all jobs. The values are securely pulled from GitHub secrets.

---

## 🔨 **Job 1: `build-backend`**

**Steps:**

1. **Checkout code**: Retrieves the latest code.
2. **Build backend Docker image**: Uses the `Dockerfile` in `backend-app/`, tags as `latest`.
3. **Save and upload image**: Saves the image as a `.tar` file and uploads as an artifact (`backend-image`) to be shared with other jobs.

---

## 🌐 **Job 2: `build-frontend`**

**Steps:**

1. **Checkout code**.
2. **Extract version** from `frontend-app/package.json` using `jq`, save it in `version.txt`.
3. **Upload version** file as an artifact (`version`).
4. **Build frontend Docker image**, tag as `latest`.
5. **Save and upload** frontend image as an artifact (`frontend-image`).

---

## 📦 **Job 3: `push-images`**

**Dependencies:** `build-frontend`, `build-backend`

**Steps:**

1. **Download artifacts**: Retrieves `frontend.tar`, `backend.tar`, and `version.txt`.
2. **Read version** into GitHub environment.
3. **Configure AWS credentials** using `aws-actions/configure-aws-credentials@v2`.
4. **Login to Amazon ECR**.
5. **Tag and push backend image** to ECR:

   * Tag as `aws_account_id.dkr.ecr.region.amazonaws.com/backend-app:$VERSION`
6. **Tag and push frontend image** similarly.

---

## ✋ **Job 4: `manual-approval`** - Just Placeholder approval can be added in github enterprise

**Dependencies:** `push-images`

**Steps:**

* Dummy job that does nothing but requires **manual approval** to proceed.
* Runs under `environment: helm-approval` which can be configured in GitHub Environments to enforce human gatekeeping (optional reviewers, etc.).

---

## 🧠 **Job 5: `update-helm-chart`**

**Dependencies:** `manual-approval`

**Steps:**

1. **Download version** from artifacts.
2. **Set version as ENV variable**.
3. **Clone the Helm chart repo** `saifali1035/eks-app-helm-chart` using `HELM_REPO_TOKEN` for access.
4. **Create a feature branch** named `update-images-$VERSION`.
5. **Update the Helm values.yaml**:

   * Uses `sed` to find and replace the Docker tag version.
   * Assumes both frontend and backend tags are the same.
6. **Check for changes** using `git diff --quiet` to avoid redundant PRs.
7. **Push branch and create Pull Request**:

   * Title: `Update image tags to $VERSION`
   * Body: Auto-generated
   * Base: `master`
   * Head: `update-images-$VERSION`
   * Uses GitHub CLI (`gh pr create`) to create the PR automatically.

---

## 🔒 **Security**

* Uses **GitHub Secrets** for:

  * AWS credentials
  * ECR push
  * Private Helm repo access (`HELM_REPO_TOKEN`)
* Builds and pushes are isolated in separate jobs with artifacts used to pass images.

---

## ✅ **Benefits**

* Fully automated CI/CD pipeline for EKS
* Controlled, versioned deployments
* Decouples image build from deployment
* Enforces manual approval before Helm update
* Avoids unnecessary PRs via diff check

---

Let me know if you want to:

* Add support for `qa` or `prod` environments
* Use ArgoCD to auto-deploy after Helm update
* Integrate test cases or static analysis before push



# DevOps Pipeline Case Study Report

## Project Overview

This project showcases an end-to-end CI/CD pipeline to build, test, provision, configure, and deploy a Node.js application on AWS Free Tier using popular DevOps tools and industry practices.

---

## Tools & Technologies Used

- **Git & GitHub** – Version control and pull-request workflows
- **Docker & DockerHub** – Containerization and image registry
- **Terraform** – Infrastructure provisioning
- **Ansible** – Configuration management
- **Jenkins** – CI/CD pipeline automation
- **Shell Scripting** – Automation and cleanup tasks
- **AWS Free Tier** – Cloud platform (t2.micro instance)

---

## Architecture Diagram

The following diagram outlines the full flow of the CI/CD pipeline:

<img width="1772" height="602" alt="image" src="https://github.com/user-attachments/assets/468dbda8-b6dc-4da9-916e-99183269c47e" />

---

## Branching Strategy

We followed a simplified Git workflow based on Git Flow principles:

main –
This branch contains the production-ready and stable code.
All successful changes are eventually merged here after thorough testing.

develop –
This is the active development branch.
New features, bug fixes, and experimental work are integrated here first.
It acts as a staging area before merging into main.

---

### Git Commands Used:
```bash
# Create a new feature branch
git checkout develop
git checkout -b feature/some-feature

# After development
git add .
git commit -m "Add some feature"
git push origin feature/some-feature

# Merge to develop via Pull Request or locally
git checkout develop
git merge feature/some-feature

# Merge to main when develop is stable
git checkout main
git merge develop

```
<img width="2878" height="1714" alt="image" src="https://github.com/user-attachments/assets/6aa3c737-3abb-47d2-98a3-77b39fcff6fe" />

<img width="2878" height="1714" alt="image" src="https://github.com/user-attachments/assets/7c03cb13-ae30-47ce-8b79-9bb188d9d19a" />

<img width="2878" height="1714" alt="image" src="https://github.com/user-attachments/assets/770cd5b7-cd14-4bb6-90bf-c7d8edece47b" />

---

## Dockerization

**Dockerfile**:
- Based on official `node:alpine` image.
- Copies `src/` directory and installs dependencies.
- Exposes port 3000 for the Node.js application.

```dockerfile
FROM node:18-alpine

WORKDIR /usr/src/app

COPY src/ ./src/
COPY package*.json ./

RUN npm install

EXPOSE 3000

CMD ["node", "src/index.js"]

```
<img width="2544" height="1444" alt="image" src="https://github.com/user-attachments/assets/c9f3770b-3b53-4b10-8845-8fafdd22aa18" />


<img width="2764" height="1664" alt="image" src="https://github.com/user-attachments/assets/2e20f06e-5311-434e-995f-1ae35b32b11b" />


**Script: `scripts/build_and_push.sh`**

```bash
#!/bin/bash

# Exit immediately if a command fails
set -e

# Variables
IMAGE_NAME="varshitanukala/nodeapp"
TAG="latest"

# Login to DockerHub
echo "Logging in to DockerHub..."
echo "$DOCKERHUB_PASSWORD" | docker login -u "$varshitanukala" --password-stdin

# Build Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME:$TAG myapp/

# Push Docker image
echo "Pushing Docker image to DockerHub..."
docker push $IMAGE_NAME:$TAG

echo "Docker image pushed successfully!"

```

---

## Terraform Resource Summary

**Location**: `infra/`

### Terraform Provisions:
- VPC with a single public subnet
- t2.micro EC2 instance (Ubuntu)
- Security group allowing SSH (22) and HTTP (80)
- Elastic IP associated with the EC2 instance

**Terraform Commands Used:**
```bash
cd infra
terraform init
terraform plan
terraform apply -auto-approve
```

**Input Variables:**
- `region`
- `instance_type`

<img width="1394" height="1022" alt="image" src="https://github.com/user-attachments/assets/3a005511-1ed2-4aa4-92ef-3b8a07c16957" />

<img width="2880" height="1616" alt="image" src="https://github.com/user-attachments/assets/9b14b175-b8c5-4d3e-b76a-ab53c0ac30ea" />


---

## Ansible Configuration

**Inventory File**: `ansible/hosts.ini`

```ini
[web]
<EC2_PUBLIC_IP> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/key.pem
```

**Playbook**: `ansible/deploy.yml`

```yaml
---
- name: Deploy Node.js application
  hosts: app
  become: yes

  tasks:
    - name: Update system packages
      yum:
        name: '*'
        state: latest

    - name: Install required packages
      yum:
        name:
          - nodejs
          - npm
          - rsync
        state: present

    - name: Create app directory on EC2
      file:
        path: /home/ec2-user/myapp
        state: directory
        owner: ec2-user
        group: ec2-user
        mode: '0755'

    - name: Sync application files (excluding node_modules)
      synchronize:
        src: ../myapp/src/
        dest: /home/ec2-user/myapp/
        rsync_opts:
          - "--exclude=node_modules"
      delegate_to: localhost
      become: false

    - name: Install Node.js dependencies
      npm:
        path: /home/ec2-user/myapp
        production: yes

    - name: Install PM2 globally
      npm:
        name: pm2
        global: yes

    - name: Start the Node.js app with PM2
      shell: pm2 start index.js --name myapp --update-env
      args:
        chdir: /home/ec2-user/myapp/

```

**Execution Command**:
```bash
ansible-playbook -i ansible/hosts.ini ansible/deploy.yml
```

<img width="1646" height="1162" alt="image" src="https://github.com/user-attachments/assets/eb237c86-d852-40e2-948a-a4a3386d417e" />


<img width="2880" height="1800" alt="image" src="https://github.com/user-attachments/assets/907e0e71-cb3f-4dba-97f1-b0d9f2937c5f" />


<img width="2880" height="1714" alt="image" src="https://github.com/user-attachments/assets/02c28710-d3bb-4d7b-9bb1-f76b813bac88" />


---

## Jenkins CI/CD Pipeline

A Jenkins server was set up (on a t2.micro EC2 or locally) with required plugins for Git, Docker, Terraform, and Ansible.

**Jenkinsfile** (placed in `myapp/`):

```groovy
pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('varshitanukala')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'develop', url: 'https://github.com/nukalavarshita/devops-nodejs-pipeline.git'
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'varshitanukala', usernameVariable: 'varshitanukala', passwordVariable: 'xxxxx')]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$varshitanukala" --password-stdin
                        chmod +x scripts/build_and_push.sh
                        ./scripts/build_and_push.sh
                    '''
                }
            }
        }

        stage('Provision Infrastructure with Terraform') {
            steps {
                dir('infra') {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Deploy App with Ansible') {
            steps {
                sh 'ansible-playbook -i ansible/hosts.ini ansible/deploy.yml'
            }
        }
    }

    post {
        success {
            echo 'Deployment pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs for details.'
        }
    }
}

```

### Pipeline Trigger:
- Push to `develop` triggers Jenkins pipeline

### Outcome:
- App gets built, pushed to DockerHub, EC2 infra provisioned, container deployed, and app goes live.


<img width="2880" height="1715" alt="image" src="https://github.com/user-attachments/assets/3110d2fa-5999-4891-8c52-31a1ebf50650" />

---

## Shell Scripting & Cleanup

### `scripts/cleanup.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "Starting Docker cleanup..."

echo "Removing dangling Docker images..."
docker image prune -f --filter "dangling=true"

echo "Pruning unused Docker containers..."
docker container prune -f

echo "Pruning unused Docker networks..."
docker network prune -f

echo "Docker cleanup completed successfully!"

```

### Features:
- `set -euo pipefail` ensures safe and strict execution
- Logs every action taken

### Execution:
```bash
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh
```

<img width="1646" height="1162" alt="image" src="https://github.com/user-attachments/assets/c2fe5afd-98d4-4381-99f3-d965f41b8fb1" />


---

## Final Deliverables

- **GitHub Repo**: [https://github.com/nukalavarshita/devops-nodejs-pipeline](https://github.com/nukalavarshita/devops-nodejs-pipeline)
- `Dockerfile` in `myapp/`
- `build_and_push.sh` in `scripts/`
- `main.tf` and `variables.tf` in `infra/`
- `deploy.yml` and `hosts.ini` in `ansible/`
- `Jenkinsfile` for full pipeline
- `REPORT.md` with architecture diagram

---

## Learning Outcomes

Implemented Git-based collaboration via branches and PRs  
Built and pushed Docker images using scripting  
Provisioned secure cloud infrastructure using Terraform  
Automated deployment using Ansible  
End-to-end CI/CD pipeline with Jenkins  
Cleaned up environment with robust shell scripts

---

_This case study project mirrors real-world DevOps pipelines and delivers practical experience integrating all stages from code to deployment._

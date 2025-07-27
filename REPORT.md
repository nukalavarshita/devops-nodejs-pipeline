
# DevOps Case Study Report

## 1. Project Overview

This project demonstrates a complete CI/CD pipeline for a Node.js application using Git, GitHub, Jenkins, Docker, DockerHub, Terraform, Ansible, and shell scripting. The application is deployed on AWS infrastructure provisioned using Terraform and configured with Ansible.

---

## 2. Architecture Diagram

```
Developer → GitHub → Jenkins → DockerHub
                        ↓         ↓
                   Terraform → AWS EC2
                        ↓
                   Ansible → Node.js App Running
```

---

## 3. Git Workflow

- **Main Branch**: `main`
- **Development Branch**: `develop`
- Feature branches are created from `develop` and merged via pull requests.

---

## 4. Terraform Summary

- **Provider**: AWS
- **Resources Created**:
  - 1 EC2 instance (t2.micro)
  - Security group allowing SSH and port 3000
- **Files**:
  - `infra/main.tf`
  - `infra/variables.tf`

---

## 5. Jenkins Pipeline

### Jenkinsfile Stages:
1. **Clone**: Checkout from `develop` branch.
2. **Build & Push**: Use `scripts/build_and_push.sh` to build Docker image and push to DockerHub.
3. **Terraform Apply**: Apply infrastructure in `infra/` directory.
4. **Ansible Deploy**: Deploy application via Ansible to EC2 instance.

---

## 6. Ansible Summary

- Inventory: `ansible/hosts.ini`
- Playbook: `ansible/deploy.yml`
- Installs Docker, pulls app image, and runs container on EC2 instance.

---

## 7. Shell Scripting

- **scripts/build_and_push.sh**: Builds and pushes Docker image.
- **scripts/cleanup.sh**: Cleans dangling images and prunes networks using:
  ```bash
  set -euo pipefail
  ```

---

## 8. Pipeline Execution Proof

1. Code change pushed to `develop`
2. Jenkins pulled code and executed pipeline:
   - Docker image built and pushed to DockerHub
   - EC2 provisioned via Terraform
   - App deployed via Ansible

### Screenshot Proofs:
- Jenkins build logs
- DockerHub pushed image
- EC2 instance running
- App accessible via public IP

---

## 9. Repository Structure

```
devops-nodejs-pipeline/
├── myapp/
│   ├── Jenkinsfile
│   └── src/
│       └── index.js
├── infra/
│   ├── main.tf
│   └── variables.tf
├── ansible/
│   ├── deploy.yml
│   └── hosts.ini
├── scripts/
│   ├── build_and_push.sh
│   └── cleanup.sh
└── REPORT.md
```

---

## 10. Conclusion

This case study demonstrates an end-to-end DevOps pipeline for deploying a Node.js app using modern tools and best practices in CI/CD, infrastructure as code, and automation.

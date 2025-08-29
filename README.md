# Go Web App — Helm + GitHub Actions + Argo CD\n

Developer Guide – CI/CD with GitHub Actions, ACR, Helm, and Argo CD

This project uses GitHub Actions to automatically build, push, and deploy our Go-based application (go-web) into our Kubernetes cluster via GitOps (Argo CD).

📂 Workflow Overview

The workflow file is located at:
.github/workflows/build-push-update-values.yaml

It runs on every push to main branch, if changes are detected in:

web-app/** → Go source code or Dockerfile changes

.github/workflows/build-push-update-values.yaml → pipeline changes

⚙️ What the Pipeline Does

Checkout Code
Pulls the latest code so GitHub Actions has the full history.

Setup Go + Cache Dependencies

Installs Go 1.22.

Uses actions/cache to cache:

Go modules (~/go/pkg/mod)

Build cache (~/.cache/go-build)

Downloads dependencies via go mod download.

Login to Azure & ACR

Authenticates to Azure using a Service Principal.

Logs into our Azure Container Registry (ACR) using admin credentials.

Build & Push Docker Image

Builds the Docker image from web-app/Dockerfile.

Pushes the image to ACR with two tags:

Commit SHA (short, e.g., 2c38260)

latest

Example image:

devrevinciacrdemo.azurecr.io/go-web:2c38260
devrevinciacrdemo.azurecr.io/go-web:latest


Update Helm Values

Updates charts/go-web/values-acr.yaml with the new repository and tag.

Ensures our GitOps deployment (Argo CD) always deploys the latest image.

Commit & Push Updated Values

Commits the Helm values file update back to main.

This triggers Argo CD to sync changes and redeploy in the cluster.

🔑 Environment Variables & Secrets

Workflow Secrets (configured in GitHub repository settings → Secrets and variables):

AZURE_CLIENT_ID → Service principal client ID

AZURE_TENANT_ID → Azure tenant

AZURE_SUBSCRIPTION_ID → Azure subscription ID

REGISTRY_USERNAME → ACR admin username

REGISTRY_PASSWORD → ACR admin password

ACR_NAME → ACR name (e.g., devrevinciacrDemo)

Environment Variables (in workflow):

APP_NAME → application name (go-web)

NAMESPACE → Kubernetes namespace (go-web)

IMAGE_REPO → ${{ secrets.ACR_NAME }}.azurecr.io/go-web

🛠 How Developers Work with This
1. Making Code Changes

Modify code in web-app/.

Update dependencies (go mod tidy) if required.

Commit and push to main (or PR → merge).

2. Workflow Trigger

On push to main, the workflow runs automatically.

It builds, pushes the Docker image, and updates Helm values.

3. Deployment via Argo CD

Argo CD watches charts/go-web/values-acr.yaml.

Once the pipeline updates this file with the new tag, Argo CD syncs and deploys the latest image to the AKS cluster.

🔍 Debugging Common Issues
Issue	Cause	Fix
ImagePullBackOff in Kubernetes	AKS cannot pull image from ACR	Ensure AKS cluster has --attach-acr configured OR add imagePullSecrets
Could not create a role assignment for ACR	You don’t have Owner role in subscription	Ask an Owner to grant RBAC permissions
Cache warnings (folder doesn’t exist)	Go cache path missing on first run	Ignore – cache will populate after first successful run
Workflow fails on docker/login	Wrong REGISTRY_USERNAME / REGISTRY_PASSWORD	Recreate ACR credentials via az acr credential show
✅ Best Practices for Developers

Always create a feature branch → PR → merge into main.

Run go test ./... locally before pushing (tests can be added as a pipeline step too).

Keep Helm values minimal – only repository and tag are overwritten by CI.

Use short commit messages, since image tags are derived from commit SHA.

📈 Future Enhancements

Add go test ./... step before Docker build (ensures only tested code is deployed).

Replace ACR admin login with Managed Identity / OIDC for more secure auth.

Add vulnerability scanning step (e.g., Trivy or Microsoft Defender).

Implement Canary or Blue/Green deployments via Argo Rollouts.

#!/bin/bash

# CI/CD Pipeline Setup Script for Google Cloud
# This script sets up the complete pipeline automatically

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting CI/CD Pipeline Setup...${NC}"

# Get project configuration
read -p "Enter your Google Cloud Project ID: " PROJECT_ID
read -p "Enter your bucket name for static website (must be globally unique): " BUCKET_NAME
read -p "Enter your source repository name (default: flask-cicd-repo): " REPO_NAME
REPO_NAME=${REPO_NAME:-flask-cicd-repo}

echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Project ID: $PROJECT_ID"
echo "  Bucket Name: $BUCKET_NAME"
echo "  Repository Name: $REPO_NAME"
echo

# Set the project
echo -e "${BLUE}🔧 Setting up Google Cloud project...${NC}"
gcloud config set project $PROJECT_ID

# Enable required APIs
echo -e "${BLUE}🔌 Enabling required APIs...${NC}"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable sourcerepo.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com

# Create storage bucket
echo -e "${BLUE}🪣 Creating storage bucket...${NC}"
gsutil mb gs://$BUCKET_NAME || echo "Bucket might already exist, continuing..."

# Configure bucket for website hosting
echo -e "${BLUE}🌐 Configuring bucket for website hosting...${NC}"
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

# Make bucket publicly readable
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Create source repository
echo -e "${BLUE}📁 Creating source repository...${NC}"
gcloud source repos create $REPO_NAME || echo "Repository might already exist, continuing..."

# Update cloudbuild.yaml with the correct bucket name
echo -e "${BLUE}⚙️  Updating Cloud Build configuration...${NC}"
sed -i.bak "s/your-static-website-bucket/$BUCKET_NAME/g" cloudbuild.yaml
rm cloudbuild.yaml.bak 2>/dev/null || true

# Create build trigger
echo -e "${BLUE}🔨 Creating Cloud Build trigger...${NC}"
gcloud builds triggers create cloud-source-repositories \
    --repo=$REPO_NAME \
    --branch-pattern="^main$" \
    --build-config=cloudbuild.yaml \
    --name="static-website-deploy" \
    --description="Deploy static website on push to main branch" || echo "Trigger might already exist, continuing..."

# Grant Cloud Build permissions to access Cloud Storage
echo -e "${BLUE}🔐 Setting up permissions...${NC}"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLOUDBUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# Add Storage Admin role to Cloud Build service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$CLOUDBUILD_SA" \
    --role="roles/storage.admin"

echo -e "${GREEN}✅ Setup complete!${NC}"
echo
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "1. Clone your source repository:"
echo "   gcloud source repos clone $REPO_NAME"
echo "2. Copy your files to the repository directory"
echo "3. Push to the main branch to trigger deployment:"
echo "   git add ."
echo "   git commit -m 'Initial deployment'"
echo "   git push origin main"
echo
echo -e "${YELLOW}🌐 Your website will be available at:${NC}"
echo "   https://storage.googleapis.com/$BUCKET_NAME/index.html"
echo
echo -e "${BLUE}💡 To monitor builds:${NC}"
echo "   gcloud builds list"
echo "   gcloud builds log [BUILD_ID]"

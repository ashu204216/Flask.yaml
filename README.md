# 🚀 Static Website CI/CD Pipeline with Google Cloud

This project demonstrates a fully automated CI/CD pipeline that deploys a static website to Google Cloud Storage using Google Cloud Build and Google Cloud Source Repositories.

## 🏗️ Architecture

```
GitHub Repository → Google Cloud Source Repository → Cloud Build → Cloud Storage (Static Website)
```

## 📋 Prerequisites

1. **Google Cloud Account** with billing enabled
2. **Google Cloud CLI** installed and configured
3. **Git** installed
4. A **Google Cloud Project**

## 🛠️ Quick Setup

### Option 1: Automated Setup (Recommended)

1. **Install Google Cloud CLI** (if not already installed):
   ```bash
   curl https://sdk.cloud.google.com | bash
   exec -l $SHELL
   gcloud init
   ```

2. **Run the automated setup script**:
   ```bash
   ./setup-pipeline.sh
   ```

3. **Follow the prompts** to configure your project, bucket name, and repository.

### Option 2: Manual Setup

#### Step 1: Enable APIs and Set Project
```bash
# Set your project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable sourcerepo.googleapis.com
```

#### Step 2: Create Storage Bucket
```bash
# Create bucket (name must be globally unique)
gsutil mb gs://YOUR_BUCKET_NAME

# Configure for website hosting
gsutil web set -m index.html -e 404.html gs://YOUR_BUCKET_NAME

# Make publicly accessible
gsutil iam ch allUsers:objectViewer gs://YOUR_BUCKET_NAME
```

#### Step 3: Create Source Repository
```bash
# Create repository
gcloud source repos create YOUR_REPO_NAME

# Clone repository
gcloud source repos clone YOUR_REPO_NAME
```

#### Step 4: Set Up Build Trigger
```bash
# Create build trigger
gcloud builds triggers create cloud-source-repositories \
    --repo=YOUR_REPO_NAME \
    --branch-pattern="^main$" \
    --build-config=cloudbuild.yaml \
    --name="static-website-deploy" \
    --description="Deploy static website on push to main branch"
```

#### Step 5: Configure Permissions
```bash
# Get project number
PROJECT_NUMBER=$(gcloud projects describe YOUR_PROJECT_ID --format="value(projectNumber)")

# Grant Cloud Build access to Storage
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com" \
    --role="roles/storage.admin"
```

## 🚀 Deployment Process

1. **Make changes** to your website files (`index.html`, `style.css`, `script.js`)
2. **Commit and push** to the main branch:
   ```bash
   git add .
   git commit -m "Update website"
   git push origin main
   ```
3. **Automatic deployment** is triggered via Cloud Build
4. **Website is live** at `https://storage.googleapis.com/YOUR_BUCKET_NAME/index.html`

## 📁 Project Structure

```
├── index.html          # Main HTML file
├── style.css           # Stylesheet
├── script.js           # JavaScript file
├── cloudbuild.yaml     # Cloud Build configuration
├── setup-pipeline.sh   # Automated setup script
└── README.md          # This file
```

## ⚙️ Cloud Build Configuration

The `cloudbuild.yaml` file defines the build steps:

1. **Prepare files** - Copy static files to staging directory
2. **Deploy to GCS** - Sync files to Cloud Storage bucket
3. **Set permissions** - Make files publicly accessible
4. **Set cache headers** - Configure caching for better performance

## 🔧 Customization

### Adding More File Types

To include additional file types in deployment, update the `cloudbuild.yaml`:

```yaml
- name: 'gcr.io/cloud-builders/gsutil'
  entrypoint: 'bash'
  args:
    - '-c'
    - |
      mkdir -p /workspace/dist
      cp -r *.html *.css *.js *.png *.jpg *.svg /workspace/dist/
```

### Custom Domain

To use a custom domain:

1. **Create a CNAME record** pointing to `c.storage.googleapis.com`
2. **Update bucket name** to match your domain
3. **Configure SSL** using Cloud Load Balancer (optional)

### Build Notifications

Add Slack/Email notifications by adding a step to `cloudbuild.yaml`:

```yaml
- name: 'gcr.io/cloud-builders/gcloud'
  args:
    - 'builds'
    - 'list'
    - '--limit=1'
    - '--format=value(status)'
```

## 🎯 Monitoring and Troubleshooting

### View Build History
```bash
gcloud builds list
```

### View Build Logs
```bash
gcloud builds log BUILD_ID
```

### Check Bucket Contents
```bash
gsutil ls gs://YOUR_BUCKET_NAME
```

### Test Website
```bash
curl -I https://storage.googleapis.com/YOUR_BUCKET_NAME/index.html
```

## 🔒 Security Considerations

- **IAM Permissions**: Use least-privilege principle
- **Public Access**: Only grant public read access, never write
- **HTTPS**: Consider using Cloud CDN or Load Balancer for SSL
- **Secrets**: Never commit sensitive data to the repository

## 💰 Cost Optimization

- **Storage Class**: Use Standard storage for frequently accessed content
- **CDN**: Enable Cloud CDN to reduce egress costs
- **Lifecycle Rules**: Set up automatic deletion of old build artifacts
- **Regional Buckets**: Use regional buckets for better performance

## 🚨 Common Issues

### Build Fails
- Check Cloud Build service account permissions
- Verify bucket exists and is accessible
- Review build logs for specific errors

### Website Not Accessible
- Confirm bucket is publicly readable
- Check website configuration (`gsutil web get gs://BUCKET_NAME`)
- Verify files were uploaded correctly

### Permission Denied
- Ensure Cloud Build service account has Storage Admin role
- Check IAM policies on the bucket

## 📚 Additional Resources

- [Google Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Storage Static Website Hosting](https://cloud.google.com/storage/docs/hosting-static-website)
- [Cloud Source Repositories](https://cloud.google.com/source-repositories/docs)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the deployment pipeline
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Happy Deploying! 🎉**

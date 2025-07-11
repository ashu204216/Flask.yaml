echo "Pulling latest code..."
git pull origin main

echo "Building Docker image..."
docker build -t flask-app .

echo "Stopping old container..."
docker stop flask-container || true && docker rm flask-container || true

echo "Running new container..."
docker run -d -p 5000:5000 --name flask-container flask-app

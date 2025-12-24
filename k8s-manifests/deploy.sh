#!/bin/bash

echo "🚀 Deploying Voting App to Kubernetes..."

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f namespace.yaml

# Deploy configurations
echo "⚙️ Deploying ConfigMap and Secrets..."
kubectl apply -f configmaps/
kubectl apply -f secrets/

# Deploy databases
echo "💾 Deploying Redis and PostgreSQL..."
kubectl apply -f deployments/redis-deployment.yaml
kubectl apply -f deployments/postgres-deployment.yaml
kubectl apply -f services/redis-service.yaml
kubectl apply -f services/postgres-service.yaml

echo "⏳ Waiting for databases to be ready..."
kubectl wait --for=condition=ready pod -l component=cache -n voting-app --timeout=60s
kubectl wait --for=condition=ready pod -l component=database -n voting-app --timeout=60s

# Deploy worker
echo "⚙️ Deploying Worker..."
kubectl apply -f deployments/worker-deployment.yaml

# Deploy frontend apps
echo "🌐 Deploying Vote and Result apps..."
kubectl apply -f deployments/vote-deployment.yaml
kubectl apply -f deployments/result-deployment.yaml
kubectl apply -f services/vote-service.yaml
kubectl apply -f services/result-service.yaml

echo "⏳ Waiting for apps to be ready..."
kubectl wait --for=condition=ready pod -l component=vote -n voting-app --timeout=60s
kubectl wait --for=condition=ready pod -l component=result -n voting-app --timeout=60s

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 Application Status:"
kubectl get pods -n voting-app
echo ""
echo "🌐 Access URLs:"
echo "   Vote App:   http://192.168.56.10:31000"
echo "   Results:    http://192.168.56.10:31001"
echo ""

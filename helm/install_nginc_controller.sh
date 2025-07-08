#NGINX_EIP=$(terraform output -raw nginx_eip)

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

kubectl create namespace ingress-nginx
helm install nginx-controller ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type="LoadBalancer"
  

echo "Waiting for the nginx-controller to be ready"
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
echo "nginx-controller is ready"

SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
helm upgrade --install nginx-ingress "$SCRIPT_DIR/ingress"

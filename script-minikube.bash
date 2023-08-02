minikube delete

minikube start

helm install quarkus-api my-api-chart/

helm install loki grafana/loki-stack --namespace loki --create-namespace --set grafana.enabled=true

start bash -c "minikube tunnel; exec bash"

cd terraform-prometheus/

terraform init

terraform plan

terraform apply --auto-approve

start bash -c "minikube service loki-grafana -n loki; exec bash"

start bash -c "minikube service prometheus -n prometheus; exec bash"

echo "grafana password:"
kubectl get secret --namespace loki loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
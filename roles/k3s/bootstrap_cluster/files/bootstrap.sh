
kustomize build ./../kubernetes/infra/external-secrets --enable-helm  | kubectl apply -f --kubeconfig=./tmp/k3s-kubeconfig -

sleep 1

kubectl apply -f ./../kubernetes/infra/secret-store/secret-store.yaml --kubeconfig=./tmp/k3s-kubeconfig
kustomize build ./../kubernetes/infra/cert-manager --enable-helm  | kubectl apply -f --kubeconfig=./tmp/k3s-kubeconfig -

sleep 1

kubectl apply -k ./../kubernetes/infra/metallb --kubeconfig=./tmp/k3s-kubeconfig

kubectl apply -k ./../kubernetes/infra/cluster-issuer --kubeconfig=./tmp/k3s-kubeconfig

kustomize build ./../kubernetes/infra/traefik --enable-helm  | kubectl apply -f --kubeconfig=./tmp/k3s-kubeconfig -

sleep 1

kustomize build ./../kubernetes/infra/longhorn --enable-helm  | kubectl apply -f --kubeconfig=./tmp/k3s-kubeconfig -

sleep 1

kubectl apply -k ./../kubernetes/infra/argocd --kubeconfig=./tmp/k3s-kubeconfig
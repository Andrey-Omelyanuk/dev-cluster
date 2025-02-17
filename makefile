ifneq (,$(wildcard .env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

dependencies:
	bash install-local-dependencies.sh

# -------------------------------------------------------------------------
# -- Local K8S Controll Panel ---------------------------------------------
# -------------------------------------------------------------------------

add-cluster-to-local-kubectl:
	kubectl config set-cluster dev-cluster --server=http://$(HEAD_OF_CLUSTER):28080
	kubectl config set-context dev-cluster --cluster=dev-cluster

connect:
	kubectl config use-context $(CLUSTER_NAME)
	ssh andrey@$(HEAD_OF_CLUSTER) kubectl proxy --port=28080 --address=$(HEAD_OF_CLUSTER) --accept-hosts=^10.8.1.*$

# Show admin password and run Dashboard on localhost:8443 
dashboard:
	kubectl -n kubernetes-dashboard create token admin --duration=12h
	kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

# Show admin password and run ArgoCD UI on localhost:8080
argocd:
	kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath="{.data.password}" | base64 -d | tr -d '\n' && echo
	kubectl port-forward svc/argocd-server -n argocd 8080:443

# -------------------------------------------------------------------------
# -- Mannual manage app ---------------------------------------------------
# -------------------------------------------------------------------------

up:
	kubectl kustomize ./apps/$(a)/$(ENV)/ --enable-helm | kubectl apply -f -

show:
	kubectl kustomize ./apps/$(a)/$(ENV)/ --enable-helm

down:
	kubectl kustomize ./apps/$(a)/$(ENV)/ --enable-helm | kubectl delete -f -

secret:
	kubeseal --controller-name sealed-secrets \
		--format yaml < ./apps/$(a)/$(ENV)/secrets.yml > ./apps/$(a)/$(ENV)/sealed-secrets.yml 

secrets-update:
	make secret a=postgres
	make secret a=gitea
	make secret a=gitea-act-runner

# -------------------------------------------------------------------------
# -- How to test k8s apps locally -----------------------------------------
# -------------------------------------------------------------------------

install:
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
	sudo dpkg -i minikube_latest_amd64.deb
	rm minikube_latest_amd64.deb

# Note: Minikube config is close to the real dev cluster.
# Note: Don't need to setup kubectl context, it will be switched automatically
start:
	minikube start -p $(CLUSTER_NAME) --nodes=3 --memory=4096 --cpus=4 
	kubectl label node dev-cluster     node=public
	kubectl label node dev-cluster-m02 node=storage
	kubectl label node dev-cluster-m03 node=main

info:
	minikube profile list
	minikube ip -p $(CLUSTER_NAME)

stop:
	minikube stop -p $(CLUSTER_NAME)

delete:
	minikube delete --all

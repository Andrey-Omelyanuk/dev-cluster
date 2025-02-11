ifneq (,$(wildcard .env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

dependencies:
	bash install-local-dependencies.sh

# up a=<name of app>
up:
	kubectl kustomize ./apps/$(a)/$(ENV)/ --enable-helm | kubectl apply -f -

# secret a=<name of app>
secret:
	kubeseal -f ./apps/$(a)/$(ENV)/secrets.yml -w ./apps/$(a)/$(ENV)/sealed-secrets.yml 

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
# -- How to test k8s apps locally -----------------------------------------
# -------------------------------------------------------------------------

# 0. Install minikube
test-install:
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
	sudo dpkg -i minikube_latest_amd64.deb

# 1. Start minikube
# Note: Don't need to setup kubectl context, it will be switched automatically
test-start:
	minikube start --memory=16384 --cpus=8

# 2. Stop minikube
test-stop:
	minikube stop 

# 3. Delete minikube
test-clear:
	minikube delete --all

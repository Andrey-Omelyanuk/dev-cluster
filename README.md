Kustomize configs of apps.
--------------------------
ArgoCD use it to install/update the apps on the dev cluster.


Motivation:
-----------
Helm charts are bad things to customize. We need full customize way.


Apps
---- 
- ArgoCD
- Kubernates Dashboard
- Monitoring + Logs
- Sealed Secrets
- PostgreSQL
- Redis 
- MongoDB
- MinIO 
- Gitea
- Gitea Act Runner
- Apache Superset
- Apache Airflow
- Dagster
- PG Back Web
- KeyCloak
- Syncthing
- OpenReplay
- Redash
- Sentry


================================================
Base declare:
- deployments / stateful-set
- service

Env declare:
- namespace
- configs
- secrets / sealed-secrets
- pvc
- ingress / NodePort service
- PATCH: deployments / stateful-set 



redis-cluster-staging:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	helm -n redis upgrade -i -f redis-values-staging.yml redis bitnami/redis --create-namespace

redis-cluster-production:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	helm -n redis upgrade -i -f redis-values-production.yml redis bitnami/redis --create-namespace

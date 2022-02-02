redis-cluster:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	helm -n redis upgrade -i -f redis-values.yml redis bitnami/redis --create-namespace

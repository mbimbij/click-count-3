redis-cluster:
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo update
	helm -n redis upgrade -i -f redis-values.yml redis bitnami/redis --create-namespace

install-click-count:
	helm -n click-count upgrade -i click-count click-count --create-namespace

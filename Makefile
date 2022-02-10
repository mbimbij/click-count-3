include props.env

requires-environment-set:
	@if [ -z $(ENVIRONMENT) ]; then >&2 echo "ENVIRONMENT is not set"; exit 255; fi

MASTER_STACK_NAME=$(APPLICATION_NAME)-master-stack
all: s3-bucket
	mkdir -p infra/packaged-templates
	aws cloudformation package --template-file infra/master-stack.yml --output-template infra/packaged-templates/master-stack.yml --s3-bucket $(S3_BUCKET_NAME)
	echo "AWS_REGION $(AWS_REGION)"
	envsubst < infra/master-stack-parameters.json  > infra/packaged-templates/master-stack-parameters.json
	aws cloudformation deploy --stack-name $(MASTER_STACK_NAME) --template-file infra/packaged-templates/master-stack.yml --parameter-overrides file://infra/packaged-templates/master-stack-parameters.json --capabilities CAPABILITY_NAMED_IAM
	$(MAKE) github-actions
	$(MAKE) post-process-eks-cluster ENVIRONMENT=staging
	$(MAKE) post-process-eks-cluster ENVIRONMENT=production
delete-all:
	- $(MAKE) -j2 delete-s3-bucket delete-github-actions
	- $(MAKE) delete-eks-lb ENVIRONMENT=staging
	- $(MAKE) delete-eks-lb ENVIRONMENT=production
	infra/stack-deletion/delete-stack-wait-termination.sh $(MASTER_STACK_NAME)
post-process-eks-cluster: requires-environment-set
	aws eks update-kubeconfig --name cluster-$(APPLICATION_NAME)-$(ENVIRONMENT)
	- eksctl delete iamidentitymapping --cluster cluster-$(APPLICATION_NAME)-$(ENVIRONMENT) --arn arn:aws:iam::$(AWS_ACCOUNT_ID):role/github-oidc-role
	eksctl create iamidentitymapping --cluster cluster-$(APPLICATION_NAME)-$(ENVIRONMENT) --arn arn:aws:iam::$(AWS_ACCOUNT_ID):role/github-oidc-role --group system:masters --username $(APPLICATION_NAME)-operations

S3_BUCKET_NAME=$(APPLICATION_NAME)-$(AWS_ACCOUNT_ID)-$(AWS_REGION)-bucket
s3-bucket::
	aws cloudformation deploy    \
          --stack-name $(S3_BUCKET_NAME)   \
          --template-file infra/s3-bucket/s3-bucket.yml   \
          --parameter-overrides     \
            BucketName=$(S3_BUCKET_NAME)
delete-s3-bucket:
	infra/stack-deletion/delete-stack-wait-termination.sh $(S3_BUCKET_NAME)

delete-eks-lb: requires-environment-set
	aws eks update-kubeconfig --name cluster-$(APPLICATION_NAME)-$(ENVIRONMENT)
	kubectl -n $(APPLICATION_NAME) delete svc $(APPLICATION_NAME)

github-actions:
	@if [ -z $(GITHUB_PAT) ]; then >&2 echo "GITHUB_PAT is not set"; exit 255; fi
	cd infra/pipeline/github-actions; \
	pwd; \
	terraform init; \
	terraform apply -var='PAT=$(GITHUB_PAT)' \
					-var='AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID)' \
					-var='AWS_REGION=$(AWS_REGION)' \
					-var='REPOSITORY_NAME=$(REPOSITORY_NAME)' \
					-var='APPLICATION_NAME=$(APPLICATION_NAME)' \
					-auto-approve ;
delete-github-actions:
	@if [ -z $(GITHUB_PAT) ]; then >&2 echo "GITHUB_PAT is not set"; exit 255; fi
	cd infra/pipeline/github-actions; \
	pwd; \
	terraform init; \
	terraform destroy -var='PAT=$(GITHUB_PAT)' \
					-var='AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID)' \
					-var='AWS_REGION=$(AWS_REGION)' \
					-var='REPOSITORY_NAME=$(REPOSITORY_NAME)' \
					-var='APPLICATION_NAME=$(APPLICATION_NAME)' \
					-auto-approve ;

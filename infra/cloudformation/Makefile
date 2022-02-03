include infra.env

ifndef APPLICATION_NAME
$(error APPLICATION_NAME is not set)
endif

ifndef AWS_REGION
AWS_REGION := $(shell aws configure get region)
endif

AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query "Account" --output text)
MASTER_STACK_NAME=$(APPLICATION_NAME)-master-stack

all: s3-bucket github-oidc-trust
	mkdir -p packaged-templates
	aws cloudformation package --template-file master-stack.yml --output-template packaged-templates/master-stack.yml --s3-bucket $(S3_BUCKET_NAME)
	echo "AWS_REGION $(AWS_REGION)"
	envsubst < master-stack-parameters.json  > packaged-templates/master-stack-parameters.json
	aws cloudformation deploy --stack-name $(MASTER_STACK_NAME) --template-file packaged-templates/master-stack.yml --parameter-overrides file://packaged-templates/master-stack-parameters.json --capabilities CAPABILITY_NAMED_IAM
	$(MAKE) post-process
delete-all:
	$(MAKE) -j2 delete-s3-bucket delete-github-oidc-trust
	stack-deletion/delete-stack-wait-termination.sh $(MASTER_STACK_NAME)
post-process:
	- eksctl delete iamidentitymapping --cluster cluster-$(APPLICATION_NAME)-staging --arn arn:aws:iam::$(AWS_ACCOUNT_ID):role/github-oidc-role
	eksctl create iamidentitymapping --cluster cluster-$(APPLICATION_NAME)-staging --arn arn:aws:iam::$(AWS_ACCOUNT_ID):role/github-oidc-role --group system:masters --username $(APPLICATION_NAME)-operations

S3_BUCKET_NAME=$(APPLICATION_NAME)-$(AWS_ACCOUNT_ID)-$(AWS_REGION)-bucket
export S3_BUCKET_NAME
s3-bucket::
	aws cloudformation deploy    \
          --stack-name $(S3_BUCKET_NAME)   \
          --template-file s3-bucket/s3-bucket.yml   \
          --parameter-overrides     \
            BucketName=$(S3_BUCKET_NAME)
delete-s3-bucket:
	stack-deletion/delete-stack-wait-termination.sh $(S3_BUCKET_NAME)

github-oidc-trust:
	aws cloudformation deploy --stack-name github-oidc-provider --template-file pipeline/github-oidc-provider-trust.yml  --parameter-overrides GitHubOrg=$(GITHUB_USER_NAME) RepositoryName=$(GITHUB_REPO_NAME) --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
delete-github-oidc-trust:
	stack-deletion/delete-stack-wait-termination.sh github-oidc-provider


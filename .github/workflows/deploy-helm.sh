#!/bin/bash
  aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
  curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
  helm upgrade -i click-count -n click-count --create-namespace deploy/helm-charts/click-count/ --set imageName=$IMAGE_FULLNAME --set application.redisHost=$REDIS_HOST

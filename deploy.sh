#!/bin/bash

SHA1=$1
IMAGE_NAME=324320755747.dkr.ecr.us-west-2.amazonaws.com/casey-test:$CIRCLE_SHA1

# Push image
eval `aws ecr get-login`
docker tag python-api $TAG
docker push $TAG

# Create new Elastic Beanstalk version
EB_BUCKET=casey-labs-bucket
DOCKERRUN_FILE=$SHA1-Dockerrun.aws.json
sed "s/<NAME>/$IMAGE_NAME/" < Dockerrun.aws.json.template > $DOCKERRUN_FILE
aws s3 cp $DOCKERRUN_FILE s3://$EB_BUCKET/$DOCKERRUN_FILE
aws elasticbeanstalk create-application-version --application-name casey-test \
  --version-label $SHA1 --source-bundle S3Bucket=$EB_BUCKET,S3Key=$DOCKERRUN_FILE

# Update Elastic Beanstalk environment to new version
aws elasticbeanstalk update-environment --environment-name casey-test-env \
    --version-label $SHA1
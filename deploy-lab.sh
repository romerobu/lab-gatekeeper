#!/bin/bash

LAB_NAME=$1
VERSION=$2
ENV=$3

source $3

LAB_HOME=/tmp/$LAB_NAME-$VERSION

echo $LAB_HOME

# create tmp folder for target files
mkdir -p $LAB_HOME

cp docker/Dockerfile  $LAB_HOME/Dockerfile
cp -r $LAB_NAME/images $LAB_HOME

asciidoctor -D $LAB_HOME $LAB_NAME/index.adoc -d book

pushd $LAB_HOME

# build image
podman build . -t $REGISTRY/$LAB_NAME:$VERSION 
podman push $REGISTRY/$LAB_NAME:$VERSION

# deploy
oc login -u $OCP_USER $OCP_API
oc new-project $OCP_NS
# use -o yaml to be able to update changes once it is created
oc new-app  --name=$LAB_NAME \
  --docker-image=$REGISTRY/$LAB_NAME:$VERSION \
  -n $OCP_NS -o yaml | oc apply -f - -n $OCP_NS

oc expose svc/$LAB_NAME -n $OCP_NS 

echo ""

oc get route $LAB_NAME -n $OCP_NS

popd

rm -rf  $LAB_HOME



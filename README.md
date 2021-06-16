# lab-opa-gatekeeper


# init users
sudo ./init-ocp-user.sh kubeadmin https://api.cluster-4a3f.sandbox453.opentlc.com:6443  users/user-redhat.list


#Run lab local
sudo podman run -p 8080:8080 quay.io/romerobu/lab-gatekeeper:latest

# Build and run image:
LAB_NAME=lab-gatekeeper
VERSION=latest
REGISTRY=quay.io/romerobu
LAB_HOME=/tmp/$LAB_NAME-$VERSION
echo $LAB_HOME
mkdir -p $LAB_HOME
cp docker/Dockerfile  $LAB_HOME/Dockerfile
cp -r $LAB_NAME/images $LAB_HOME
asciidoctor -D $LAB_HOME $LAB_NAME/index.adoc -d book
pushd $LAB_HOME
sudo podman build . -t $REGISTRY/$LAB_NAME:$VERSION 
sudo podman push $REGISTRY/$LAB_NAME:$VERSION

# Deploy lab 
sudo ./deploy-lab.sh lab-gatekeeper latest  env/cromerob.env

------------------------------------

export OCP_CONSOLE=https://console-openshift-console.apps.cluster-4a3f.sandbox453.opentlc.com

export OCP_API=https://api.cluster-4a3f.sandbox453.opentlc.com:6443

export OCP_USER=kubeadmin

export OCP_PASSWORD=h6Wss-s3unH-ZCmNp-7LYLK

export APPS_NS=deploy-app

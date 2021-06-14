#!/bin/bash

CLUSTER_ADMIN_USER=$1
OCP_API=$2
PATH_TO_USERS_FILE=$3
TMP_FILE=htpasswd

# will be ask for password if not set in coxtext yet
oc login -u $CLUSTER_ADMIN_USER $OCP_API

cat $PATH_TO_USERS_FILE | while read line ;
do 
    user=`echo $line | awk -F# '{print $1}'`
    pass=`echo $line | awk -F# '{print $2}'`
    # add user to htpasswd file
    htpasswd -nbm $user $pass  >> $TMP_FILE
done

cat $TMP_FILE

oc create secret generic htpasswd --from-file=$TMP_FILE -n openshift-config

oc apply -f lab-gatekeeper-files/role/oauth-config.yaml

rm -rf $TMP_FILE
echo "Waiting some time to get OAuth configured..."
sleep 30
echo "OAuth should has been now updated"


# Install operator and create gatekeeper and config

# Set up gatekeeper operator

oc apply -f config/install-operator.yaml

echo -n "Waiting for pods ready..."
while [[ $(oc get pods  -n openshift-operators  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -n "." && sleep 1; done; echo -n -e "  [OK]\n"

sleep 5

# Create gatekeeper instance

echo -n "Creating gatekeeper..."
oc apply -f config/create-gatekeeper.yaml

echo -n "Waiting for pods ready..."
while [[ $(oc get pods  -n openshift-gatekeeper-system  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; do echo -n "." && sleep 1; done; echo -n -e "  [OK]\n"

sleep 5

# Create config resource

oc apply -f config/config.yaml


echo "Create namespace and roles"
# Create namespace and add roles
cat $PATH_TO_USERS_FILE | while read line ;
do
    user=`echo $line | awk -F# '{print $1}'`
    echo $user
    # create namespace
    oc new-project petclinic-bluegreen-$user
    oc new-project petclinic-beta-$user
    # add role
    oc apply -f lab-gatekeeper-files/role/clusterrole.yaml
    oc adm policy add-cluster-role-to-user gatekeeper-ops-role $user
    oc adm policy add-role-to-user admin $user -n petclinic-bluegreen-$user
    oc adm policy add-role-to-user view $user -n openshift-gatekeeper-system
    oc adm policy add-role-to-user admin $user -n petclinic-beta-$user
    # create resource quota in beta namespace
    oc apply -f lab-gatekeeper-files/lab5/rs.yaml -n petclinic-beta-$user
done



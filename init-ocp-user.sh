#!/bin/bash

CLUSTER_ADMIN_USER=$1
OCP_API=$2
PATH_TO_USERS_FILE=$3
TMP_FILE=users-tmp

# will be ask for password if not set in coxtext yet
oc login -u $CLUSTER_ADMIN_USER $OCP_API
oc get secret htpasswd -n openshift-config -o yaml \
  | grep htpasswd | grep -v "{}" \
  | awk -F": " '{print $2}' | base64 -d > $TMP_FILE
cat $PATH_TO_USERS_FILE | while read line ;
do 
    user=`echo $line | awk -F# '{print $1}'`
    pass=`echo $line | awk -F# '{print $2}'`
    # add user to htpasswd file
    htpasswd -nbm $user $pass  >> $TMP_FILE
done
cat $TMP_FILE
USERS_CONTENT=`cat $TMP_FILE | base64 -w 0`
echo "$USERS_CONTENT"
oc patch secret  htpasswd --type='json' \
  -p='[{"op": "add", "path": "/data/htpasswd", "value":"'${USERS_CONTENT}'"}]' \
  -n openshift-config
rm -rf $TMP_FILE
echo "Waiting some time to get OAuth configured..."
sleep 30
echo "OAuth should has been now updated"
# cat $PATH_TO_USERS_FILE | while read line ;
# do 
#     user=`echo $line | awk -F# '{print $1}'`
#     pass=`echo $line | awk -F# '{print $2}'`
#     ns=`echo $line | awk -F# '{print $3}'`
#     oc login -u $user -p $pass $OCP_API
#     # create ns
#     oc new-project $ns
# done

# Set up gatekeeper operator

oc apply -f lab-gatekeeper-files/petclinic/install-operator.yaml

echo -n "Waiting for pods ready..."
while [[ $(oc get pods  -n openshift-operators  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo -n "." && sleep 1; done; echo -n -e "  [OK]\n"

sleep 5

# Create gatekeeper instance

echo -n "Creating gatekeeper..."
oc apply -f lab-gatekeeper-files/petclinic/create-gatekeeper.yaml

echo -n "Waiting for pods ready..."
while [[ $(oc get pods  -n openshift-gatekeeper-system  -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True True True" ]]; do echo -n "." && sleep 1; done; echo -n -e "  [OK]\n"

sleep 5

# Deploy config

echo -n "Deploying config..."
#oc apply -f lab-gatekeeper-files/petclinic/config.yaml
oc process -f config/config.yaml  -p USER=$USER  | oc apply -f -

# Create namespace and add roles
oc get secret htpasswd -n openshift-config -o yaml \
  | grep htpasswd | grep -v "{}" \
  | awk -F": " '{print $2}' | base64 -d > $TMP_FILE
cat $PATH_TO_USERS_FILE | while read line ;
do
    user=`echo $line | awk -F# '{print $1}'`
    pass=`echo $line | awk -F# '{print $2}'`
    # create namespace
    oc new-project petclinic-bluegreen-$user
    oc new-project petclinic-beta-$user
    # add role
    oc adm policy add-cluster-role-to-user gatekeeper-ops-role $user
    oc adm policy add-role-to-user admin $user -n petclinic-bluegreen-$user
    oc adm policy add-role-to-user view $user -n openshift-gatekeeper-system
    oc adm policy add-role-to-user view $user -n openshift-operators 
    oc adm policy add-role-to-user admin $user -n petclinic-beta-$user
    # create resource quota in beta namespace
    oc apply -f lab-gatekeeper-files/lab5/rs.yaml -n petclinic-beta-$user
done

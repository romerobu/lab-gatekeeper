#!/bin/bash

CLUSTER_ADMIN_USER=$1
OCP_API=$2
PATH_TO_USERS_FILE=$3
TMP_FILE=users-tmp

# will be ask for password if not set in coxtext yet
oc login -u $CLUSTER_ADMIN_USER $OCP_API
oc get secret htpass-secret -n openshift-config -o yaml \
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
oc patch secret  htpass-secret --type='json' \
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


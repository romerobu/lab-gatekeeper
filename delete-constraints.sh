#!/bin/bash

oc delete resourcequota.constraints.gatekeeper.sh/resourcequota
oc delete requiredlabelsroute.constraints.gatekeeper.sh/required-label-route
oc delete maxreplicas.constraints.gatekeeper.sh/maxreplicas
oc delete containerratio.constraints.gatekeeper.sh/container-ratio
oc delete requiredlabelsdeployment.constraints.gatekeeper.sh/required-label-deployment
oc delete requiredroutename.constraints.gatekeeper.sh/required-route-name
oc delete requiredlabelssvc.constraints.gatekeeper.sh/required-label-service
oc delete constraintTemplate containerratio
oc delete constraintTemplate maxreplicas
oc delete constraintTemplate requiredlabelsdeployment
oc delete constraintTemplate requiredlabelsroute
oc delete constraintTemplate requiredlabelssvc
oc delete constraintTemplate requiredroutename
oc delete constraintTemplate resourcequota

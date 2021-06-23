#!/bin/bash

oc delete requiredresourcequota.constraints.gatekeeper.sh/requiredresourcequota${USER}
oc delete requiredlabelsroute.constraints.gatekeeper.sh/required-label-route-${USER}
oc delete maxreplicas.constraints.gatekeeper.sh/maxreplicas${USER}
oc delete containerratio.constraints.gatekeeper.sh/container-ratio-${USER}
oc delete requiredlabelsdeployment.constraints.gatekeeper.sh/required-label-deployment-${USER}
oc delete requiredroutename.constraints.gatekeeper.sh/required-route-name-${USER}
oc delete requiredlabelssvc.constraints.gatekeeper.sh/required-label-service-${USER}
oc delete constraintTemplate containerratio
oc delete constraintTemplate maxreplicas
oc delete constraintTemplate requiredlabelsdeployment
oc delete constraintTemplate requiredlabelsroute
oc delete constraintTemplate requiredlabelssvc
oc delete constraintTemplate requiredroutename
oc delete constraintTemplate requiredresourcequota

#!/bin/bash

oc apply -f lab-gatekeeper-files/lab1/constraintTemplate.yaml
oc apply -f lab-gatekeeper-files/lab2/constraintTemplateDeployment.yaml
oc apply -f lab-gatekeeper-files/lab2/constraintTemplateRoute.yaml
oc apply -f lab-gatekeeper-files/lab2/constraintTemplateSvc.yaml
oc apply -f lab-gatekeeper-files/lab3/constraintTemplate.yaml
oc apply -f lab-gatekeeper-files/lab4/constraintTemplate.yaml
oc apply -f lab-gatekeeper-files/lab5/constraintTemplate.yaml

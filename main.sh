#!/bin/bash

# Copy pull_secret from openshift-config to open-cluster-management-observability

DOCKER_CONFIG_JSON=`oc extract secret/pull-secret -n openshift-config --to=-`

oc create secret generic multiclusterhub-operator-pull-secret \
    -n open-cluster-management-observability \
    --from-literal=.dockerconfigjson="$DOCKER_CONFIG_JSON" \
    --type=kubernetes.io/dockerconfigjson

# Create secret for thanos.yaml

S3_ENDPOINT=`oc get routes -n openshift-storage s3 -o jsonpath='{.spec.host}'`
S3_ACCESS_KEY=`oc get secret noobaa-admin -n openshift-storage -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 -d`
S3_SECRET_KEY=`oc get secret noobaa-admin -n openshift-storage -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 -d`

cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
  namespace: open-cluster-management-observability
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: acm.observability
      endpoint: $S3_ENDPOINT
      insecure: true
      access_key: $S3_ACCESS_KEY
      secret_key: $S3_SECRET_KEY
EOF

exit 0
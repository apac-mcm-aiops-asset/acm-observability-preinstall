#!/bin/bash

# Copy pull_secret from openshift-config to open-cluster-management-observability

DOCKER_CONFIG_JSON=`oc extract secret/pull-secret -n openshift-config --to=-`

oc create secret generic multiclusterhub-operator-pull-secret \
    -n open-cluster-management-observability \
    --from-literal=.dockerconfigjson="$DOCKER_CONFIG_JSON" \
    --type=kubernetes.io/dockerconfigjson

# Create secret for thanos.yaml

S3_BUCKET_NAME=`oc get cm acm-observability-obc -n open-cluster-management-observability -o jsonpath='{.data.BUCKET_NAME}'`
S3_ENDPOINT=`oc get cm acm-observability-obc -n open-cluster-management-observability -o jsonpath='{.data.BUCKET_HOST}'`
S3_ENDPOINT_PORT=`oc get cm acm-observability-obc -n open-cluster-management-observability -o jsonpath='{.data.BUCKET_PORT}'`
S3_ACCESS_KEY=`oc get secret acm-observability-obc -n open-cluster-management-observability -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 -d`
S3_SECRET_KEY=`oc get secret acm-observability-obc -n open-cluster-management-observability -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 -d`

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
      bucket: $S3_BUCKET_NAME
      endpoint: $S3_ENDPOINT:$S3_ENDPOINT_PORT
      insecure: true
      access_key: $S3_ACCESS_KEY
      secret_key: $S3_SECRET_KEY
EOF

exit 0
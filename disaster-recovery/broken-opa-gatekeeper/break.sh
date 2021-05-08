#!/bin/bash

echo "Breaking OPA Gatekeeper.."

echo "Changing the failurePolicy to Fail..."
kubectl get ValidatingWebhookConfiguration gatekeeper-validating-webhook-configuration -o yaml | sed 's/failurePolicy.*/failurePolicy: Fail/g' | kubectl apply -f -

echo "Scaling deployments to zero..."
kubectl -n gatekeeper-system scale --replicas=0 deploy/gatekeeper-audit
kubectl -n gatekeeper-system scale --replicas=0 deploy/gatekeeper-controller-manager
kubectl -n gatekeeper-system get pods -o wide

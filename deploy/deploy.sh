#!/usr/bin/env sh

set -eux

# Create the namespace
kubectl create namespace $NAMESPACE || true

# Delete Kubernetes secret if exists
kubectl delete secret odk-service-account enketo --namespace $NAMESPACE || true

# Create GCP service account file
cat $GOOGLE_APPLICATION_CREDENTIALS >> ./service-account.json

# Recreate service account file as Kubernetes secret
kubectl create secret generic odk-service-account \
    --namespace $NAMESPACE \
    --from-file=key.json=./service-account.json

kubectl create secret generic enketo --namespace $NAMESPACE --from-literal=enketo-api-key="$ENKETO_API_KEY"

helm upgrade \
    --install \
    --debug \
    --create-namespace \
    --namespace "${NAMESPACE}" \
    --set service.port="${BACKEND_PORT}"\
    --set service.frontendport="${FRONTEND_PORT}"\
    --set app.container.env.sysAdminEmail="${SYSADMIN_EMAIL}"\
    --set app.container.env.databaseInstanceConnectionName="${DB_INSTANCE_CONNECTION_NAME}"\
    --set app.container.env.dbHost="${DB_HOST}"\
    --set app.container.env.dbUser="${DB_USER}"\
    --set app.container.env.dbPassword="${DB_PASSWORD}"\
    --set app.container.env.dbName="${DB_NAME}"\
    --set app.container.env.dbSSL="${DB_SSL}"\
    --set app.container.env.enketoApiKey="${ENKETO_API_KEY}"\
    --set networking.issuer.name="letsencrypt-prod"\
    --set networking.issuer.privateKeySecretRef="letsencrypt-prod"\
    --set networking.ingress.host="${BACKEND_APP_DOMAIN}"\
    --set networking.enketo.ingress.host="${ENKETO_DOMAIN}"\
    --set networking.frontend.ingress.host="${FRONTEND_APP_DOMAIN}"\
    --wait \
    --timeout 300s \
    -f ./charts/odk-central/values.yaml \
    $APP_NAME \
    ./charts/odk-central
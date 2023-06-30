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
    --set app.replicaCount="${APP_REPLICA_COUNT}" \
    --set service.port="${PORT}"\
    --set service.frontendport="${FRONTEND_PORT}"\
    --set app.container.env.domain="${DOMAIN}"\
    --set app.container.env.sysAdminEmail="${SYSADMIN_EMAIL}"\
    --set app.container.env.databaseInstanceConnectionName="${DB_INSTANCE_CONNECTION_NAME}"\
    --set app.container.env.dbHost="${DB_HOST}"\
    --set app.container.env.dbUser="${DB_USER}"\
    --set app.container.env.dbPassword="${DB_PASSWORD}"\
    --set app.container.env.dbName="${DB_NAME}"\
    --set app.container.env.dbSSL="${DB_SSL}"\
    --set app.container.env.httpsPort="${HTTPS_PORT}"\
    --set app.container.env.nodeOptions="${NODE_OPTIONS}"\
    --set app.container.env.emailFrom="${EMAIL_FROM}"\
    --set app.container.env.emailHost="${EMAIL_HOST}"\
    --set app.container.env.emailPort="${EMAIL_PORT}"\
    --set app.container.env.emailSecure="${EMAIL_SECURE}"\
    --set app.container.env.emailIgnoreTls="${EMAIL_IGNORE_TLS}"\
    --set app.container.env.emailUser="${EMAIL_USER}"\
    --set app.container.env.emailPassword="${EMAIL_PASSWORD}"\
    --set app.container.env.sentryOrgSubdomain="${SENTRY_ORG_SUBDOMAIN}"\
    --set app.container.env.sentryKey="${SENTRY_KEY}"\
    --set app.container.env.sentryProject="${SENTRY_PROJECT}"\
    --set networking.issuer.name="letsencrypt-prod"\
    --set networking.issuer.privateKeySecretRef="letsencrypt-prod"\
    --set networking.ingress.host="${APP_DOMAIN}"\
    --set networking.frontend.ingress.host="${FRONTEND_APP_DOMAIN}"\
    --wait \
    --timeout 300s \
    -f ./charts/odk-central/values.yaml \
    $APP_NAME \
    ./charts/odk-central
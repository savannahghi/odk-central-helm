# odk-central-helm
A Helm chart repository that contains Helm charts for deploying ODK Central

## Deployment to Google Kubernetes Engine (GKE)
This guide provides step-by-step instructions for deploying your applications to Google Kubernetes Engine (GKE).

To ensure an efficient deployment process, we leverage [Helm](https://helm.sh/), a powerful package manager for Kubernetes, to orchestrate the deployment of our charts to [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/). There's a `deploy.sh` file in the deploy folder that does the magic. 

#### Utilizing the helm upgrade Command
To deploy your applications to GKE, the helm upgrade command is used within the `deploy.sh` script. This command serves as the cornerstone of your deployment process and allows for seamless updates. Here is how the command is structured:

```bash
helm upgrade \
    --install \
    --debug \
    --create-namespace \
    --namespace "${NAMESPACE}" \
    --wait \
    --timeout 300s \
    -f ./charts/odk-central/values.yaml \
    $APP_NAME \
    ./charts/odk-central
```

### Prerequisites 
* GKE cluster up and running in your Google Cloud Platform (GCP) project. 
* Cloud SQL set up, including creating a database, user, and password.

### Environment variables
In your CI environment (GitHub Actions), set the following environment variables to be used during the deployment process:

```bash
APP_NAME: Name of your application release
APP_REPLICA_COUNT: Number of replicas to create for a pod 
BACKEND_APP_DOMAIN: Domain for the ODK Backend deploy (e.g. example.com) 
BACKEND_PORT: Port that the backend application exposes in Kubernetes (usually 8383).
CLUSTER_NAME: Name of the GKE cluster you've created 
DB_HOST: Your database host (usually localhost due to Cloud SQL Proxy)
DB_INSTANCE_CONNECTION_NAME: Cloud SQL instance connection name
DB_NAME: Name of your database
DB_PASSWORD: Password for the database user
DB_SSL: Whether to use SSL for the database connection
DB_USER: Database user
ENKETO_API_KEY: API key for Enketo
ENKETO_DOMAIN: Domain for the Enketo application (e.g., enketo.something.com)
FRONTEND_APP_DOMAIN: Domain for the frontend application (the ODK Central UI)
FRONTEND_PORT: Port for the frontend application (usually 80)
GKE_PROJECT: Your Google Cloud project
GKE_ZONE: Zone where the GKE cluster is deployed (e.g., europe-west1-b)
GOOGLE_APPLICATION_CREDENTIALS: Google Cloud service account JSON key file.
GOOGLE_CLOUD_PROJECT: Google Cloud project
NAMESPACE: Namespace that will be created for your applications
SYSADMIN_EMAIL: Email address for the system administrator
```

### Create a user and password to log into ODK Central
After the service is deployed, exec into the backend service pod, and create a user (and promote if required)

```bash
kubectl exec -it <backend-service-pod> -- bash
odk-cmd -u <email> user-create
odk-cmd -u <email> user-promote
```
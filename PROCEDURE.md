# Procedure

## Preparation

```sh
gcloud config configurations list
gcloud config configurations activate [config-name]
gcloud auth application-default login
```

## Initialize

```sh
terraform init
terraform apply
```

### Impersonation

```sh
task init
```

or

```sh
gcloud iam service-accounts add-iam-policy-binding "projects/${PROJECT_ID_PREFIX}-pipeline/serviceAccounts/releaser@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com" \
  --member "user:$(gcloud config get account)" \
  --role roles/iam.serviceAccountTokenCreator
gcloud iam service-accounts add-iam-policy-binding "projects/${PROJECT_ID_PREFIX}-pipeline/serviceAccounts/stg-promoter@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com" \
  --member "user:$(gcloud config get account)" \
  --role roles/iam.serviceAccountTokenCreator
gcloud iam service-accounts add-iam-policy-binding "projects/${PROJECT_ID_PREFIX}-pipeline/serviceAccounts/prod-promoter@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com" \
  --member "user:$(gcloud config get account)" \
  --role roles/iam.serviceAccountTokenCreator
```

## Deploy

### Build

```sh
task build APP_VERSION="1.0.0"
```

or

```sh
cd deploy
gcloud config set project ${PROJECT_ID_PREFIX}-pipeline
export APP_VERSION=v1.0.1
gcloud config set auth/impersonate_service_account "releaser@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com"
skaffold build \
  --filename skaffold.yaml \
  --default-repo "${REGION}-docker.pkg.dev/${PROJECT_ID_PREFIX}-pipeline/pipeline-repo" \
  --file-output artifacts.json
gcloud config unset auth/impersonate_service_account
```

### Deploy to dev

```sh
task deploy:dev RELEASE_NAME=v1-0-0
```

or

```sh
gcloud config set project "${PROJECT_ID_PREFIX}-pipeline"
export RELEASE_NAME="v1-0-0"
gcloud deploy releases create ${RELEASE_NAME} \
  --region="asia-northeast1" \
  --delivery-pipeline="app-pipeline" \
  --gcs-source-staging-dir "gs://${PROJECT_ID_PREFIX}-pipeline-storage/app/source" \
  --build-artifacts artifacts.json \
  --skaffold-file skaffold.yaml \
  --enable-initial-rollout \
  --impersonate-service-account "releaser@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com"
```

### Promote to stg

```sh
task deploy:stg RELEASE_NAME=v1-0-0
```

or

```sh
gcloud config set project "${PROJECT_ID_PREFIX}-pipeline"
export RELEASE_NAME="v1-0-0"
gcloud deploy releases promote \
  --release ${RELEASE_NAME} \
  --delivery-pipeline app-pipeline \
  --region ${REGION} \
  --impersonate-service-account "stg-promoter@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com"
```

### Promote to prod

```sh
task deploy:prod RELEASE_NAME=v1-0-0
```

or

```sh
gcloud config set project "${PROJECT_ID_PREFIX}-pipeline"
export RELEASE_NAME="v1-0-0"
gcloud deploy releases promote \
  --release ${RELEASE_NAME} \
  --delivery-pipeline app-pipeline \
  --region ${REGION} \
  --impersonate-service-account "prod-promoter@${PROJECT_ID_PREFIX}-pipeline.iam.gserviceaccount.com"
```

## GitHub Actions

Set the following variables for GitHub Actions:

- WIF_PROJECT_NUM: GCP project number for Workload Identity Federation
- WIF_POOL_ID: Workload Identity Pool ID
- WIF_PROVIDER_ID: Workload Identity Provider ID
- PIPELINE_PROJECT_ID: GCP project ID for Cloud Deploy (e.g., ${PROJECT_ID_PREFIX}-pipeline)
- ARTIFACT_REGISTRY_REPO: Artifact Registry repository name (e.g., pipeline-repo)
- GCP_REGION

Alternatively, execute this:

```sh
cd github-tf
terraform init
terraform apply
```

## Cleanup

```sh
terraform destroy
gcloud projects delete ${PROJECT_ID_PREFIX}-tf
```

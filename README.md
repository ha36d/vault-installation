# Vault

## Usage
The format is [https://34.86.254.128:8200/](https://34.86.254.128:8200/).

### Installation 
In our case, It can be either used with GUI or CLI:
sso:

    export VAULT_ADDR=https://34.86.254.128:8200
    export VAULT_CACERT="terraform/service/ca.crt"
    vault login token=something

### Installation

    gcloud auth login --no-launch-browser
    export GCP_PROJECT_ID="project-id"
    gcloud services enable --project "${GCP_PROJECT_ID}" compute.googleapis.com
    echo 'project_id = "'${GCP_PROJECT_ID}'"' > terraform/service/terraform.tfvars
    # service
    cd terraform/service/; terraform init; terraform apply -auto-approve
    # management
    cd terraform/management/; terraform init; terraform apply -auto-approve

# S3 website + CloudFront

Terraform template for a S3 website with a CloudFront distribution.

## Setup S3 state backend

```
terraform init \
-backend-config="bucket=${TFSTATE_BUCKET}" \
-backend-config="key=${TFSTATE_KEY}" \
-backend-config="region=${TFSTATE_REGION}"
```
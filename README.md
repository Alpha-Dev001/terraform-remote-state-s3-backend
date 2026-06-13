# Terraform Remote State Setup

![Terraform Checks](https://github.com/YOUR_USERNAME/terraform-remote-state-s3-backend/actions/workflows/terraform.yml/badge.svg)

Reusable backend for Terraform state using S3 (storage) + DynamoDB (locking).

## Structure

```
terraform-remote-state/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── state-backend/
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── example-project/
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── shared-backend-config/
│   └── backend.hcl.example
├── docs/
│   └── remote-state.md
└── .gitignore
```

- `.github/workflows/` - CI: runs fmt check + validate on push/PR
- `state-backend/` - creates the S3 bucket + DynamoDB table (local state)
- `example-project/` - sample project that uses the remote backend
- `shared-backend-config/` - backend.hcl template for other projects
- `docs/` - notes on how/why this works

## 1. Bootstrap the backend (one-time)

Runs with local state since it creates the backend itself.

```powershell
cd state-backend
terraform init
terraform apply -var="bucket_name=yourname-terraform-state-prod"
terraform output
```

## 2. Point another project at it

Copy `shared-backend-config/backend.hcl.example` to `backend.hcl`, fill in
the bucket/table/region from the outputs above, and give it a unique `key`:

```hcl
bucket         = "yourname-terraform-state-prod"
key            = "envs/dev/networking/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
```

Add an empty backend block:

```hcl
terraform {
  backend "s3" {}
}
```

Then:

```powershell
terraform init -backend-config=backend.hcl
```

## 3. Try the example project

```powershell
cd example-project
Copy-Item ..\shared-backend-config\backend.hcl.example backend.hcl
# edit backend.hcl: bucket/region/dynamodb_table from state-backend outputs,
# key = "envs/dev/example-project/terraform.tfstate"

terraform init -backend-config=backend.hcl
terraform apply -var="bucket_name=yourname-example-bucket-dev"
```

## Notes

- `prevent_destroy = true` on the bucket, so it can't get wiped accidentally.
- Don't commit `*.tfstate` or real `backend.hcl` files.
- See `docs/remote-state.md` for more detail.
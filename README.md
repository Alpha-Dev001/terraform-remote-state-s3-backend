# Terraform Remote State Setup

Reusable backend for Terraform state using S3 (storage) + DynamoDB (locking).

## Structure

```
terraform-remote-state/
├── state-backend/
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

- `state-backend/` - creates the S3 bucket + DynamoDB table (local state)
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

## Notes

- `prevent_destroy = true` on the bucket, so it can't get wiped accidentally.
- Don't commit `*.tfstate` or real `backend.hcl` files.
- See `docs/remote-state.md` for more detail.

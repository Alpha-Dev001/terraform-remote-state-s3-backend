# Terraform Remote State Setup

This project sets up a reusable, secure remote backend for Terraform state
using **AWS S3** (storage) and **DynamoDB** (state locking).

## Structure
terraform-remote-state/

├── state-backend/              # Bootstraps the S3 bucket + DynamoDB table

│   ├── providers.tf

│   ├── variables.tf

│   ├── main.tf

│   └── outputs.tf

├── shared-backend-config/

│   └── backend.hcl.example     # Template for other projects to use this backend

├── docs/

│   └── remote-state.md         # Explanation of the architecture

└── .gitignore

## Step 1: Bootstrap the backend (one-time setup)

This creates the S3 bucket and DynamoDB table that *other* projects will
use as their remote backend. It runs with **local state**, since it
creates the very backend it would otherwise depend on.

```powershell
cd state-backend
terraform init
terraform plan -var="bucket_name=yourname-terraform-state-prod"
terraform apply -var="bucket_name=yourname-terraform-state-prod"
```

After applying, get the outputs:

```powershell
terraform output
```

## Step 2: Use this backend in another project

1. Copy `shared-backend-config/backend.hcl.example` to `backend.hcl` in
   your new project and fill in the values from the outputs above
   (pick a unique `key` per project/environment).
2. Add an empty backend block in that project:

```hcl
terraform {
  backend "s3" {}
}
```

3. Initialize with:

```powershell
terraform init -backend-config=backend.hcl
```

## More details

See [`docs/remote-state.md`](docs/remote-state.md) for the full explanation
of why this setup exists and how it all fits together.

## ⚠️ Important

- Never commit `*.tfstate` or `backend.hcl` (real values) — see `.gitignore`.
- The S3 bucket has `prevent_destroy = true` — it cannot be accidentally
  deleted via `terraform destroy`.
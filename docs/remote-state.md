# Remote State Setup

## The problem

Terraform's default state file (`terraform.tfstate`) lives locally on
whoever ran `apply`. That doesn't work for teams: no sharing, no locking,
no backup, and state can contain secrets in plaintext.

Fix: store state in S3, lock with DynamoDB.

## The chicken-and-egg bit

To use S3 as a backend, the bucket has to exist first. So `state-backend/`
is a one-off project that runs with **local state** to create:

- an S3 bucket (versioned, encrypted, private) for storing state
- a DynamoDB table for locking

Once that exists, every other project points at it.

## Usage

1. Bootstrap once:
```bash
   cd state-backend
   terraform init
   terraform apply -var="bucket_name=yourname-terraform-state-prod"
   terraform output
```

2. In any other project, copy `shared-backend-config/backend.hcl.example`
   to `backend.hcl`, fill in the bucket/table/region from the outputs above,
   and pick a unique `key` (path) for that project's state, e.g.:
```hcl
   bucket         = "yourname-terraform-state-prod"
   key            = "envs/dev/networking/terraform.tfstate"
   region         = "us-east-1"
   dynamodb_table = "terraform-locks"
   encrypt        = true
```

3. Add an empty backend block:
```hcl
   terraform {
     backend "s3" {}
   }
```

4. Init with:
```bash
   terraform init -backend-config=backend.hcl
```

## Notes

- `prevent_destroy = true` on the bucket — stops it being deleted by accident.
- Never commit `*.tfstate` or real `backend.hcl` files.
- DynamoDB table uses pay-per-request, so it costs basically nothing idle.
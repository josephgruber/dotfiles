---
name: Terraform Standards
paths:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.tftest.hcl"
---

# Terraform / OpenTofu Standards

## Tooling

- Default to `tofu` CLI. Use `terraform` only when the project is explicitly not yet migrated.
- Never run `tofu apply`, `terraform apply`, `tofu destroy`, or `terraform destroy` — suggest the command, let the user run it.
- `tofu plan` and `tofu validate` are safe to run freely.

## OpenTofu vs Terraform

- Note when a pattern or feature differs between OpenTofu and Terraform — user is migrating and needs to know.
- Avoid Terraform-only features (HCP-specific resources, Stacks) unless project is confirmed Terraform.
- Prefer OpenTofu-native features where they exist (e.g., `tofu test`, provider-defined functions).

## State

- Never touch remote state manually. Use `tofu state` subcommands only when explicitly asked.
- Flag any backend config changes before making them.
- Use `import` blocks (not CLI `import`) for bringing existing resources under management.
- Use `moved` blocks instead of `tofu state mv`.

## Resource Naming

- Prefer `name_prefix` over `name` for resources that support it (e.g. security groups, IAM roles/policies,
  DB subnet/parameter groups). Avoids name collisions when a module is deployed multiple times in the same
  account and allows AWS to generate a unique suffix.
- Use `name` only when a deterministic, human-readable identifier is required and collision risk is explicitly accepted.

## Sensitive data

- Flag any `nonsensitive()` usage as needing explicit review.

## Working style

- Propose a plan before modifying any `.tf` files.
- Explicitly flag blast-radius risks before making changes to running infrastructure.
- Explain tflint/trivy findings before suppressing them — never add ignore comments silently.

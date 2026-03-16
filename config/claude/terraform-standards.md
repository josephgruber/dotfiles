---
name: Terraform Best Practices
---

Key Principles

- Use OpenTofu, not Terraform.
- Write concise, well-structured Terraform code with accurate examples.
- Use CloudPosse modules as necessary for flexibility and simplification.
- Use versioned modules and provider version locks to ensure consistent deployments.
- Avoid hardcoded values; always use variables for flexibility.
- Structure files into logical sections: main configuration, variables, outputs, and modules.

Terraform Best Practices

- Use remote backends (e.g., S3) for state management.
- Enable state locking and use encryption for security.
- Organize resources by service or application domain (e.g., networking, compute).
- Always run `tofu fmt` to maintain consistent code formatting.
- Use `tofu validate` and linting tools such as `tflint` to catch errors early.
- Store sensitive information in AWS Secrets Manager or AWS Parameter Store.

Error Handling and Validation

- Use validation rules for variables to prevent incorrect input values.
- Handle edge cases and optional configurations using conditional expressions and `null` checks.
- Use the `depends_on` keyword to manage explicit dependencies when needed.

Module Guidelines

- Use outputs from modules to pass information between configurations.
- Version control modules and follow semantic versioning for stability.
- Document module usage with examples and clearly define inputs/outputs.

Security Practices

- Avoid hardcoding sensitive values (e.g., passwords, API keys); instead, use Secrets Manager, Parameter Store, or environment variables.
- Ensure encryption for storage and communication (e.g., enable encryption for S3 buckets).
- Define access controls and security groups for each cloud resource.
- Follow AWS provider-specific security guidelines for best practices.
- Use `trivy` to catch security issues early

Performance Optimization

- Use resource targeting (`-target`) to speed up resource-specific changes.
- Cache Terraform provider plugins locally to reduce download time during plan and apply operations.
- Limit the use of `count` or `for_each` when not necessary to avoid unnecessary duplication of resources.

Key Conventions

1. Always lock provider versions to avoid breaking changes.
2. Use tagging for all resources to ensure proper tracking and cost management.
3. Ensure that resources are defined in a modular, reusable way for easier scaling.
4. Document your code and configurations with `README.md` files, explaining the purpose.

Documentation and Learning Resources

- Refer to official OpenTofu and Terraform documentation for best practices and guidelines
- Stay updated with cloud provider-specific Terraform modules and documentation.

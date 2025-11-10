# Terraform Stacks Enterprise Demo

A comprehensive demonstration of HashiCorp Terraform Stacks using simple `random_pet` and `null_resource` providers. This Stack showcases enterprise patterns and best practices without requiring cloud provider credentials.

## 🎯 Purpose

This Stack is designed as a teaching tool to demonstrate all aspects of Terraform Stacks:

- **Modern file structure** with separation of concerns
- **Enterprise deployment patterns** across 4 environments
- **Component dependencies** and lifecycle management
- **Local values** for DRY configuration
- **Comprehensive outputs** with multiple data types
- **Premium features** (documented for HCP Terraform)

## 📋 What's Demonstrated

### Core Stack Concepts

✅ **Variable declarations** (`variables.tfcomponent.hcl`)
- Required `type` field for all variables
- No validation blocks (Stack limitation)
- `ephemeral` and `sensitive` patterns
- Complex object types

✅ **Provider configuration** (`providers.tfcomponent.hcl`)
- Unique `config` block pattern
- Provider aliases in block header
- Documentation of `for_each` capability

✅ **Local values** (`locals.tfcomponent.hcl`)
- Environment tier mapping
- Conditional logic based on environment
- Tag standardization
- Computed values

✅ **Component definitions** (`components.tfcomponent.hcl`)
- Component dependencies (`component.pet.name`)
- Provider assignment
- Local and remote module sources

✅ **Stack outputs** (`outputs.tfcomponent.hcl`)
- String, number, bool, list, map, object types
- All outputs require `type` declaration
- Outputs for linked Stacks

✅ **Deployments** (`deployments.tfdeploy.hcl`)
- 4 environments (dev, test, staging, production)
- Progressive configuration sizing
- Local values for DRY

### Premium Features (HCP Terraform)

The following features are documented but commented out:

🔒 **Deployment groups** - Organize deployments for applying rules
🔒 **Auto-approval rules** - Progressive restrictions by environment  
🔒 **Published outputs** - Expose outputs for linked Stacks
🔒 **Upstream inputs** - Consume outputs from other Stacks
🔒 **Variable sets (store)** - Access centralized configuration

## 🏗️ Architecture

```
Stack (pet-nulls-stack-1)
├── Components
│   ├── pet (random_pet)
│   │   └── Generates random pet names
│   └── nulls (null_resource)
│       └── Creates null resources with pet dependency
│
└── Deployments
    ├── dev (1 null, 2-word pet)
    ├── test (2 nulls, 3-word pet)
    ├── staging (3 nulls, 3-word pet)
    └── production (5 nulls, 3-word pet)
```

### Component Dependency Flow

```
pet component → nulls component
     ↓              ↓
variables → component.pet.name
locals    → null_count
```

## 🚀 Getting Started

### Prerequisites

- Terraform CLI v1.13.5 or later
- No cloud provider credentials required!

### Quick Start

1. **Initialize the Stack:**
   ```bash
   terraform stacks init
   ```

2. **Generate provider lock file:**
   ```bash
   terraform stacks providers-lock
   ```

3. **Validate configuration:**
   ```bash
   terraform stacks validate
   ```

4. **Plan a deployment:**
   ```bash
   # Plan the dev environment
   terraform stacks plan --deployment=dev
   
   # Or plan all deployments
   terraform stacks plan
   ```

5. **Apply a deployment:**
   ```bash
   # Apply just dev
   terraform stacks apply --deployment=dev
   
   # Or apply all
   terraform stacks apply
   ```

6. **View outputs:**
   ```bash
   terraform stacks outputs --deployment=dev
   ```

7. **Destroy when done:**
   ```bash
   terraform stacks destroy --deployment=dev
   ```

## 📁 File Structure

```
pet-nulls-stack-1/
├── variables.tfcomponent.hcl      # Variable declarations
├── providers.tfcomponent.hcl      # Provider configurations
├── locals.tfcomponent.hcl         # Local value computations
├── components.tfcomponent.hcl     # Component definitions
├── outputs.tfcomponent.hcl        # Stack outputs
├── deployments.tfdeploy.hcl       # Deployment configurations
├── .terraform-version             # Terraform version pinning
├── .terraform.lock.hcl            # Provider lock file
└── modules/
    ├── pet/
    │   └── main.tf                # random_pet module
    └── nulls/
        └── main.tf                # null_resource module
```

## 🎓 Learning Paths

### For Stack Beginners

1. Start with `variables.tfcomponent.hcl` - understand Stack variable rules
2. Review `components.tfcomponent.hcl` - see component dependencies
3. Examine `deployments.tfdeploy.hcl` - understand deployment patterns
4. Deploy to `dev` and observe outputs

### For Intermediate Users

1. Study `locals.tfcomponent.hcl` - conditional logic patterns
2. Review `outputs.tfcomponent.hcl` - various output types
3. Compare dev vs production deployments
4. Experiment with changing deployment inputs

### For Advanced Users

1. Uncomment deployment_group blocks (requires HCP Terraform)
2. Implement auto-approval rules
3. Create a downstream Stack consuming published outputs
4. Add upstream_input from another Stack

## 🔧 Customization Examples

### Change Environment Configuration

Edit `deployments.tfdeploy.hcl` locals block:

```hcl
locals {
  environments = {
    dev = {
      null_count = 2      # Change from 1 to 2
      pet_length = 3      # Change from 2 to 3
      pet_prefix = "demo" # Change from "dev"
    }
  }
}
```

### Add a New Deployment

```hcl
deployment "qa" {
  inputs = {
    environment         = "qa"
    pet_prefix          = "qa"
    pet_length          = 3
    null_resource_count = 2
    enable_nulls        = true
    project_name        = local.default_project
    owner               = local.default_owner
    tags                = {}
    deployment_metadata = {
      team          = "qa"
      cost_center   = "quality"
      compliance    = "internal"
      backup_policy = "daily"
    }
  }
}
```

### Disable Null Resources

Set `enable_nulls = false` in any deployment inputs.

## 📊 Key Differences: Stacks vs Traditional Terraform

| Feature | Traditional Terraform | Terraform Stacks |
|---------|----------------------|------------------|
| **File extensions** | `.tf` | `.tfcomponent.hcl`, `.tfdeploy.hcl` |
| **Provider syntax** | Direct arguments | `config` block |
| **Provider for_each** | ❌ Not supported | ✅ Supported |
| **Variable validation** | ✅ Supported | ❌ Not supported |
| **Component outputs** | `module.<name>.<output>` | `component.<name>.<output>` |
| **Deployments** | Workspaces/directories | Built-in deployment blocks |
| **State management** | Single state | Per-deployment state |

## 🔐 HCP Terraform Premium Features

To enable premium features, uncomment the relevant blocks in `deployments.tfdeploy.hcl`:

### Deployment Groups & Auto-Approval

```hcl
# 1. Define auto-approval rules FIRST
deployment_auto_approve "dev_rapid_iteration" {
  check {
    condition = context.plan.applyable
    reason    = "Plan must be applyable"
  }
}

# 2. Create deployment groups with auto_approve_checks
deployment_group "development" {
  auto_approve_checks = [
    deployment_auto_approve.dev_rapid_iteration
  ]
}

# 3. Deployments reference the group
deployment "dev" {
  inputs = { ... }
  deployment_group = deployment_group.development
}
```

### Published Outputs for Linked Stacks

```hcl
publish_output "dev_pet_name" {
  type  = string
  value = deployment.dev.pet_name
}
```

### Variable Sets (Store)

```hcl
store "varset" "shared_config" {
  name     = "my-variable-set"
  category = "terraform"
}

deployment "dev" {
  inputs = {
    notification_url = store.varset.shared_config.webhook_url
  }
}
```

## 🐛 Troubleshooting

### Error: "Unexpected block: deployment_group"

**Cause:** Premium features require HCP Terraform  
**Solution:** Ensure blocks are commented out or deploy to HCP Terraform

### Error: "nullable is not expected"

**Cause:** `nullable` attribute not supported in Stack variables  
**Solution:** Remove `nullable` from variable declarations

### Error: "validation block not expected"

**Cause:** Validation blocks not supported in Stack variables  
**Solution:** Implement validation in component modules instead

## 📚 Additional Resources

- [Terraform Stacks Documentation](https://developer.hashicorp.com/terraform/docs/stacks)
- [Terraform Stacks GA Release Notes](https://www.hashicorp.com/blog/terraform-stacks-ga)
- [HCP Terraform](https://cloud.hashicorp.com/products/terraform)

## 📄 License

Copyright (c) HashiCorp, Inc.  
SPDX-License-Identifier: MPL-2.0

---

**Built with ❤️ to teach Terraform Stacks patterns**

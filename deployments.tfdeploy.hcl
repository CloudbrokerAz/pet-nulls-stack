# ============================================================================
# DEPLOYMENT CONFIGURATION FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates enterprise deployment patterns:
# - Multiple environments (dev, test, staging, production)
# - Deployment groups for organizing related deployments
# - Auto-approval rules with progressive restrictions
# - Published outputs for linked Stacks
# - Local values for DRY configuration
# ============================================================================
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# ----------------------------------------------------------------------------
# Local Values
# ----------------------------------------------------------------------------
# Common configuration shared across deployments
locals {
  default_project = "terraform-stacks-demo"
  default_owner   = "platform-engineering"
  
  # Environment-specific configurations
  environments = {
    dev = {
      null_count = 1
      pet_length = 2
      pet_prefix = "dev"
    }
    test = {
      null_count = 2
      pet_length = 3
      pet_prefix = "test"
    }
    staging = {
      null_count = 3
      pet_length = 3
      pet_prefix = "staging"
    }
    production = {
      null_count = 5
      pet_length = 3
      pet_prefix = "prod"
    }
  }
}

# ============================================================================
# DEPLOYMENT GROUPS
# ============================================================================
# Best Practice: Always create deployment groups, even for single deployments
# This enables future auto-approval rules and maintains consistent patterns

# ----------------------------------------------------------------------------
# Development Deployment Group
# ----------------------------------------------------------------------------
deployment_group "development" {
  deployments = [
    deployment.dev,
    deployment.test
  ]
}

# ----------------------------------------------------------------------------
# Pre-Production Deployment Group
# ----------------------------------------------------------------------------
deployment_group "pre_production" {
  deployments = [
    deployment.staging
  ]
}

# ----------------------------------------------------------------------------
# Production Deployment Group
# ----------------------------------------------------------------------------
deployment_group "production" {
  deployments = [
    deployment.production
  ]
}

# ============================================================================
# AUTO-APPROVAL RULES
# ============================================================================
# Progressive restrictions from development to production

# ----------------------------------------------------------------------------
# Development Auto-Approval
# ----------------------------------------------------------------------------
# Liberal auto-approval for development environments
# Allows up to 50 changes automatically
deployment_auto_approve "development_changes" {
  deployment_group = deployment_group.development
  
  check {
    condition = context.plan.applyable
    reason    = "Plan must be successful without errors"
  }
  
  check {
    condition = context.plan.changes.total <= 50
    reason    = "Development environments limited to 50 changes for safety"
  }
}

# ----------------------------------------------------------------------------
# Staging Auto-Approval
# ----------------------------------------------------------------------------
# More restrictive: no deletions, smaller change limit, business hours only
deployment_auto_approve "staging_safe_changes" {
  deployment_group = deployment_group.pre_production
  
  check {
    condition = context.plan.applyable
    reason    = "Plan must be successful"
  }
  
  check {
    condition = context.plan.changes.remove == 0
    reason    = "Staging environment cannot auto-approve resource deletions"
  }
  
  check {
    condition = context.plan.changes.total <= 10
    reason    = "Staging limited to 10 changes maximum"
  }
  
  check {
    condition = context.plan.timestamp.hour >= 9 && context.plan.timestamp.hour <= 17
    reason    = "Staging changes only approved during business hours (9 AM - 5 PM UTC)"
  }
}

# ----------------------------------------------------------------------------
# Production Auto-Approval
# ----------------------------------------------------------------------------
# Most restrictive: manual approval required for all changes
# This demonstrates the pattern even though it effectively requires manual approval
deployment_auto_approve "production_manual_only" {
  deployment_group = deployment_group.production
  
  check {
    condition = context.plan.applyable
    reason    = "Plan must be successful"
  }
  
  check {
    condition = context.plan.changes.total == 0
    reason    = "Production requires manual approval for all changes"
  }
}

# ============================================================================
# DEPLOYMENTS
# ============================================================================

# ----------------------------------------------------------------------------
# Development Deployment
# ----------------------------------------------------------------------------
deployment "dev" {
  inputs = {
    environment           = "dev"
    pet_prefix            = local.environments.dev.pet_prefix
    pet_length            = local.environments.dev.pet_length
    null_resource_count   = local.environments.dev.null_count
    enable_nulls          = true
    project_name          = local.default_project
    owner                 = local.default_owner
    tags = {
      CostCenter = "engineering"
      AutoShutdown = "true"
    }
    deployment_metadata = {
      team           = "platform"
      cost_center    = "engineering"
      compliance     = "internal"
      backup_policy  = "none"
    }
  }
}

# ----------------------------------------------------------------------------
# Test Deployment
# ----------------------------------------------------------------------------
deployment "test" {
  inputs = {
    environment           = "test"
    pet_prefix            = local.environments.test.pet_prefix
    pet_length            = local.environments.test.pet_length
    null_resource_count   = local.environments.test.null_count
    enable_nulls          = true
    project_name          = local.default_project
    owner                 = local.default_owner
    tags = {
      CostCenter = "qa"
      Testing = "automated"
    }
    deployment_metadata = {
      team           = "qa"
      cost_center    = "quality-assurance"
      compliance     = "internal"
      backup_policy  = "daily"
    }
  }
}

# ----------------------------------------------------------------------------
# Staging Deployment
# ----------------------------------------------------------------------------
deployment "staging" {
  inputs = {
    environment           = "staging"
    pet_prefix            = local.environments.staging.pet_prefix
    pet_length            = local.environments.staging.pet_length
    null_resource_count   = local.environments.staging.null_count
    enable_nulls          = true
    project_name          = local.default_project
    owner                 = local.default_owner
    tags = {
      CostCenter = "operations"
      PreProduction = "true"
    }
    deployment_metadata = {
      team           = "sre"
      cost_center    = "operations"
      compliance     = "sox"
      backup_policy  = "hourly"
    }
  }
}

# ----------------------------------------------------------------------------
# Production Deployment
# ----------------------------------------------------------------------------
deployment "production" {
  inputs = {
    environment           = "production"
    pet_prefix            = local.environments.production.pet_prefix
    pet_length            = local.environments.production.pet_length
    null_resource_count   = local.environments.production.null_count
    enable_nulls          = true
    project_name          = local.default_project
    owner                 = local.default_owner
    tags = {
      CostCenter = "operations"
      Production = "true"
      Critical = "high"
    }
    deployment_metadata = {
      team           = "sre"
      cost_center    = "operations"
      compliance     = "sox-hipaa"
      backup_policy  = "continuous"
    }
  }
}

# ============================================================================
# PUBLISHED OUTPUTS FOR LINKED STACKS
# ============================================================================
# These outputs can be consumed by downstream Stacks using upstream_input blocks

publish_output "dev_pet_name" {
  type  = string
  value = deployment.dev.pet_name
}

publish_output "dev_environment_metadata" {
  type = object({
    environment   = string
    tier          = string
    is_production = bool
    pet_name      = string
  })
  value = deployment.dev.deployment_metadata
}

publish_output "test_pet_name" {
  type  = string
  value = deployment.test.pet_name
}

publish_output "staging_pet_name" {
  type  = string
  value = deployment.staging.pet_name
}

publish_output "production_pet_name" {
  type  = string
  value = deployment.production.pet_name
}

publish_output "all_environments" {
  type = map(string)
  value = {
    dev        = deployment.dev.pet_name
    test       = deployment.test.pet_name
    staging    = deployment.staging.pet_name
    production = deployment.production.pet_name
  }
}

# ============================================================================
# OPTIONAL: UPSTREAM INPUT EXAMPLE
# ============================================================================
# Uncomment to demonstrate consuming outputs from another Stack
#
# upstream_input "networking_stack" {
#   type   = "stack"
#   source = "app.terraform.io/my-org/my-project/networking-stack"
# }
#
# Then reference in deployment inputs:
#   vpc_id = upstream_input.networking_stack.vpc_id
#
# ============================================================================

# ============================================================================
# OPTIONAL: VARIABLE SET (STORE) INTEGRATION
# ============================================================================
# Uncomment to demonstrate HCP Terraform Variable Sets
#
# store "varset" "shared_config" {
#   name     = "shared-infrastructure-config"
#   category = "terraform"
# }
#
# Then reference in deployment inputs:
#   notification_webhook = store.varset.shared_config.webhook_url
#
# Remember: Variables receiving store values must be declared as ephemeral = true
# ============================================================================

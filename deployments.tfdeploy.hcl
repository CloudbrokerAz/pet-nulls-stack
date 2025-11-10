# ============================================================================
# DEPLOYMENT CONFIGURATION FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates enterprise deployment patterns:
# - Multiple environments (dev, test, staging, production)
# - Local values for DRY configuration
# - Deployment groups with auto-approval rules (HCP Terraform Premium)
# - Published outputs for linked Stacks (HCP Terraform Premium)
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
# AUTO-APPROVAL RULES (HCP Terraform Premium)
# ============================================================================
# Define these BEFORE deployment_group blocks that reference them

# # Development: Liberal auto-approval for rapid iteration
# deployment_auto_approve "dev_rapid_iteration" {
#   check {
#     condition = context.plan.applyable
#     reason    = "Plan must be applyable"
#   }
#   
#   check {
#     condition = context.plan.changes.total <= 50
#     reason    = "Development allows up to 50 changes (current: ${context.plan.changes.total})"
#   }
# }
# 
# # Test: Moderate guardrails - no resource deletion
# deployment_auto_approve "test_safe_changes" {
#   check {
#     condition = context.plan.applyable
#     reason    = "Plan must be applyable"
#   }
#   
#   check {
#     condition = context.plan.changes.remove == 0
#     reason    = "Test environment cannot auto-approve resource deletions"
#   }
#   
#   check {
#     condition = context.plan.changes.total <= 20
#     reason    = "Test allows up to 20 changes (current: ${context.plan.changes.total})"
#   }
# }
# 
# # Staging: Strict guardrails with business hours enforcement
# deployment_auto_approve "staging_gated" {
#   check {
#     condition = context.plan.applyable
#     reason    = "Plan must be applyable"
#   }
#   
#   check {
#     condition = context.plan.changes.remove == 0
#     reason    = "Staging cannot auto-approve resource deletions"
#   }
#   
#   check {
#     condition = context.plan.changes.total <= 10
#     reason    = "Staging allows maximum 10 changes (current: ${context.plan.changes.total})"
#   }
#   
#   check {
#     condition = context.plan.timestamp.hour >= 9 && context.plan.timestamp.hour < 17
#     reason    = "Staging only auto-approves during business hours (9 AM - 5 PM UTC)"
#   }
# }

# ============================================================================
# DEPLOYMENT GROUPS (HCP Terraform Premium)
# ============================================================================
# Groups apply auto_approve_checks to their member deployments
# Deployments join groups via: deployment_group = deployment_group.development

# # Development Group: dev + test deployments with liberal auto-approval
# deployment_group "development" {
#   auto_approve_checks = [
#     deployment_auto_approve.dev_rapid_iteration
#   ]
# }
# 
# # Test Group: test deployment with moderate guardrails
# deployment_group "test" {
#   auto_approve_checks = [
#     deployment_auto_approve.test_safe_changes
#   ]
# }
# 
# # Pre-Production Group: staging deployment with strict guardrails
# deployment_group "pre_production" {
#   auto_approve_checks = [
#     deployment_auto_approve.staging_gated
#   ]
# }
# 
# # Production Group: NO auto_approve_checks = manual approval required
# deployment_group "production" {
#   # No auto_approve_checks means manual approval required for production
# }

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
  
  # deployment_group = deployment_group.production  # Uncomment for HCP Terraform
}

# ============================================================================
# PUBLISHED OUTPUTS FOR LINKED STACKS (HCP Terraform Premium)
# ============================================================================

# # Individual environment outputs
# publish_output "dev_pet_name" {
#   type  = string
#   value = deployment.dev.pet_name
# }
# 
# publish_output "dev_environment_metadata" {
#   type = object({
#     environment   = string
#     tier          = string
#     is_production = bool
#     pet_name      = string
#   })
#   value = deployment.dev.deployment_metadata
# }
# 
# publish_output "test_pet_name" {
#   type  = string
#   value = deployment.test.pet_name
# }
# 
# publish_output "staging_pet_name" {
#   type  = string
#   value = deployment.staging.pet_name
# }
# 
# publish_output "production_pet_name" {
#   type  = string
#   value = deployment.production.pet_name
# }
# 
# publish_output "all_environments" {
#   type = map(string)
#   value = {
#     dev        = deployment.dev.pet_name
#     test       = deployment.test.pet_name
#     staging    = deployment.staging.pet_name
#     production = deployment.production.pet_name
#   }
# }

# ============================================================================
# UPSTREAM INPUT EXAMPLE (HCP Terraform Premium)
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

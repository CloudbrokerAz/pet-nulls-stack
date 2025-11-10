# ============================================================================
# LOCALS FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates local value patterns:
# - Environment tier mapping (dev/test/staging/prod)
# - Conditional logic based on deployment context
# - Tag standardization and inheritance
# - Computed values from variables
# ============================================================================

locals {
  # --------------------------------------------------------------------------
  # Environment Tier Mapping
  # --------------------------------------------------------------------------
  # Maps environment names to tiers for applying tier-specific configurations
  environment_tier = {
    dev        = "development"
    test       = "testing"
    staging    = "pre-production"
    production = "production"
  }
  
  # Get the current environment's tier (defaults to 'development' if not found)
  current_tier = lookup(local.environment_tier, var.environment, "development")
  
  # --------------------------------------------------------------------------
  # Environment Classification
  # --------------------------------------------------------------------------
  # Boolean flags for conditional component behavior
  is_production     = var.environment == "production"
  is_pre_production = contains(["staging", "production"], var.environment)
  is_development    = contains(["dev", "test"], var.environment)
  
  # --------------------------------------------------------------------------
  # Resource Sizing Based on Environment
  # --------------------------------------------------------------------------
  # Demonstrates environment-specific scaling
  null_count = local.is_production ? var.null_resource_count * 2 : var.null_resource_count
  pet_separator = local.is_production ? "-" : "_"
  
  # --------------------------------------------------------------------------
  # Common Tags
  # --------------------------------------------------------------------------
  # Standardized tags applied to all resources
  common_tags = merge(
    {
      Environment  = var.environment
      Tier         = local.current_tier
      Project      = var.project_name
      Owner        = var.owner
      ManagedBy    = "Terraform Stacks"
      CostCenter   = var.deployment_metadata.cost_center
      Team         = var.deployment_metadata.team
      Compliance   = var.deployment_metadata.compliance
    },
    var.tags
  )
  
  # --------------------------------------------------------------------------
  # Naming Conventions
  # --------------------------------------------------------------------------
  # Consistent naming across resources
  name_prefix = "${var.project_name}-${var.environment}"
  pet_prefix  = var.pet_prefix != "" ? var.pet_prefix : var.environment
  
  # --------------------------------------------------------------------------
  # Feature Flags
  # --------------------------------------------------------------------------
  # Control which components are active based on environment
  enable_nulls_computed = var.enable_nulls && (local.is_development || var.null_resource_count > 0)
  
  # --------------------------------------------------------------------------
  # Deployment Metadata
  # --------------------------------------------------------------------------
  # Computed metadata for outputs and tracking
  deployment_info = {
    environment       = var.environment
    tier              = local.current_tier
    is_production     = local.is_production
    null_count        = local.null_count
    pet_length        = var.pet_length
    timestamp         = timestamp()
    terraform_version = "~> 1.13.5"
  }
  
  # --------------------------------------------------------------------------
  # Configuration Maps
  # --------------------------------------------------------------------------
  # Complex configurations for different environments
  environment_config = {
    dev = {
      null_count    = 1
      pet_length    = 2
      tags_required = false
    }
    test = {
      null_count    = 2
      pet_length    = 3
      tags_required = true
    }
    staging = {
      null_count    = 3
      pet_length    = 3
      tags_required = true
    }
    production = {
      null_count    = 5
      pet_length    = 3
      tags_required = true
    }
  }
  
  # Get current environment config
  current_config = lookup(local.environment_config, var.environment, local.environment_config.dev)
}

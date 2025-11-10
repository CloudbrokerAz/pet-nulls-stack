# ============================================================================
# COMPONENT DEFINITIONS FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates component patterns:
# - Component dependencies through input references
# - Provider assignment from provider blocks
# - Conditional components with count/for_each
# - Local and remote module sources
# ============================================================================
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# ----------------------------------------------------------------------------
# Pet Component
# ----------------------------------------------------------------------------
# Generates random pet names using the random_pet resource
# This is the upstream component that other components may depend on
component "pet" {
  source = "./pet"

  inputs = {
    prefix = local.pet_prefix
    length = var.pet_length
  }

  providers = {
    random = provider.random.this
  }
}

# ----------------------------------------------------------------------------
# Nulls Component
# ----------------------------------------------------------------------------
# Creates null_resource instances to demonstrate lifecycle and dependencies
# This component depends on the 'pet' component output
# 
# Key Patterns Demonstrated:
# - Component dependency: References component.pet.name
# - Conditional creation: Only created if var.enable_nulls is true
# - Local value usage: Uses local.null_count for dynamic sizing
component "nulls" {
  source = "./nulls"

  # Note: In Stacks, conditionals are handled in deployments or locals
  # This component will always be declared, but the module can handle count=0
  inputs = {
    pet       = component.pet.name
    instances = local.enable_nulls_computed ? local.null_count : 0
    tags      = local.common_tags
  }

  providers = {
    null = provider.null.this
  }
}

# ============================================================================
# ADVANCED PATTERNS
# ============================================================================

# ----------------------------------------------------------------------------
# Example: Component with for_each (Multi-Region Pattern)
# ----------------------------------------------------------------------------
# Uncomment to demonstrate deploying the same component across multiple instances
#
# component "pet_regional" {
#   for_each = toset(["us-east", "us-west", "eu-central"])
#   
#   source = "./pet"
#   
#   inputs = {
#     prefix = "${local.pet_prefix}-${each.value}"
#     length = var.pet_length
#   }
#   
#   providers = {
#     random = provider.random.this
#   }
# }

# ----------------------------------------------------------------------------
# Example: Component from Public Registry
# ----------------------------------------------------------------------------
# Uncomment to demonstrate using a module from the Terraform Registry
#
# component "example_registry" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.1.0"
#   
#   inputs = {
#     name = local.name_prefix
#     cidr = "10.0.0.0/16"
#   }
#   
#   providers = {
#     aws = provider.aws.this
#   }
# }

# ----------------------------------------------------------------------------
# Example: Component from Private Registry
# ----------------------------------------------------------------------------
# Uncomment to demonstrate using a module from HCP Terraform Private Registry
#
# component "example_private" {
#   source  = "app.terraform.io/my-org/module-name/provider"
#   version = "1.0.0"
#   
#   inputs = {
#     environment = var.environment
#   }
#   
#   providers = {
#     aws = provider.aws.this
#   }
# }


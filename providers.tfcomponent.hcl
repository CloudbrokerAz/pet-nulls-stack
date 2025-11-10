# ============================================================================
# PROVIDER CONFIGURATION FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates Stack provider patterns:
# - Providers use 'config' blocks (not direct arguments)
# - Aliases are defined in the block header: provider "<type>" "<alias>" {}
# - Supports 'for_each' meta-argument for dynamic provider configurations
# - No 'alias' argument inside the block
# ============================================================================

# ----------------------------------------------------------------------------
# Required Providers
# ----------------------------------------------------------------------------
# Specify provider sources and versions (identical to traditional Terraform)
required_providers {
  random = {
    source  = "hashicorp/random"
    version = "~> 3.3.0"
  }
  
  null = {
    source  = "hashicorp/null"
    version = "~> 3.1.0"
  }
}

# ----------------------------------------------------------------------------
# Random Provider
# ----------------------------------------------------------------------------
# Provider for generating random values (pet names, strings, integers)
# Note: Random provider has no required configuration
provider "random" "this" {
  config {
    # Random provider accepts no configuration arguments
    # This demonstrates the 'config' block pattern even for empty configurations
  }
}

# ----------------------------------------------------------------------------
# Null Provider
# ----------------------------------------------------------------------------
# Provider for null_resource and null_data_source
# Used to demonstrate resource lifecycle and dependencies
provider "null" "this" {
  config {
    # Null provider accepts no configuration arguments
    # null_resource is useful for demonstrating triggers and dependencies
  }
}

# ============================================================================
# ADVANCED PATTERN: Dynamic Provider with for_each
# ============================================================================
# This is a Stacks innovation - traditional Terraform does NOT support for_each on providers
# Uncomment to demonstrate multi-region or multi-configuration patterns
# 
# Example: Multiple random providers with different configurations
# provider "random" "configurations" {
#   for_each = toset(["config_a", "config_b"])
#   
#   config {
#     # Configuration specific to each instance
#   }
# }
#
# Reference in components:
#   providers = {
#     random = provider.random.configurations["config_a"]
#   }
# ============================================================================

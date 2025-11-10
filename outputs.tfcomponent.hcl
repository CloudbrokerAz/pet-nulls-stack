# ============================================================================
# STACK OUTPUTS FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates Stack output patterns:
# - All outputs MUST declare a 'type' field
# - Outputs reference component outputs: component.<name>.<output>
# - Support string, number, bool, list, map, object, tuple types
# - Mark sensitive outputs with 'sensitive = true'
# - These outputs are available at the Stack level
# ============================================================================

# ----------------------------------------------------------------------------
# Pet Component Outputs
# ----------------------------------------------------------------------------
# Exposes the random pet name generated

output "pet_name" {
  type        = string
  description = "The full random pet name generated (e.g., 'demo-happy-turtle-eagle')"
  value       = component.pet.name
}

output "pet_id" {
  type        = string
  description = "The unique ID of the random_pet resource"
  value       = component.pet.id
}

# ----------------------------------------------------------------------------
# Null Resource Outputs
# ----------------------------------------------------------------------------
# Exposes null_resource IDs for tracking

output "null_resource_ids" {
  type        = list(string)
  description = "List of null_resource IDs created (useful for tracking lifecycle)"
  value       = component.nulls.ids
}

output "null_resource_count" {
  type        = number
  description = "Number of null resources actually created"
  value       = length(component.nulls.ids)
}

# ----------------------------------------------------------------------------
# Environment Information
# ----------------------------------------------------------------------------
# Metadata about the current deployment

output "environment" {
  type        = string
  description = "Current environment name"
  value       = var.environment
}

output "environment_tier" {
  type        = string
  description = "Environment tier classification (development, testing, pre-production, production)"
  value       = local.current_tier
}

# ----------------------------------------------------------------------------
# Tagging Information
# ----------------------------------------------------------------------------
# Common tags applied to resources

output "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# ----------------------------------------------------------------------------
# Complex Output (Object Type)
# ----------------------------------------------------------------------------
# Demonstrates structured output with multiple fields

output "deployment_metadata" {
  type = object({
    environment       = string
    tier              = string
    is_production     = bool
    pet_name          = string
    null_count        = number
    project_name      = string
    owner             = string
  })
  description = "Comprehensive deployment metadata object"
  value = {
    environment       = var.environment
    tier              = local.current_tier
    is_production     = local.is_production
    pet_name          = component.pet.name
    null_count        = local.null_count
    project_name      = var.project_name
    owner             = var.owner
  }
}

# ----------------------------------------------------------------------------
# Computed Outputs
# ----------------------------------------------------------------------------
# Outputs derived from locals and variables

output "name_prefix" {
  type        = string
  description = "Computed name prefix used across resources"
  value       = local.name_prefix
}

output "is_production_deployment" {
  type        = bool
  description = "Boolean flag indicating if this is a production deployment"
  value       = local.is_production
}

# ============================================================================
# OUTPUTS FOR LINKED STACKS
# ============================================================================
# These outputs are designed to be published for consumption by downstream Stacks
# Use these with publish_output blocks in deployments.tfdeploy.hcl

output "stack_outputs_for_publishing" {
  type = object({
    pet_name          = string
    environment       = string
    tier              = string
    common_tags       = map(string)
  })
  description = "Structured outputs intended for publishing to downstream Stacks"
  value = {
    pet_name          = component.pet.name
    environment       = var.environment
    tier              = local.current_tier
    common_tags       = local.common_tags
  }
}

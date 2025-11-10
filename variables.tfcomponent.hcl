# ============================================================================
# VARIABLE DECLARATIONS FOR TERRAFORM STACKS
# ============================================================================
# This file demonstrates Stack variable best practices:
# - All variables MUST declare a 'type' field
# - Validation blocks are NOT supported (validate in component modules instead)
# - Use 'ephemeral = true' for sensitive values like tokens, passwords, or store values
# - Use 'sensitive = true' to hide values in logs and output
# - Use 'nullable = false' to enforce required values
# ============================================================================

# ----------------------------------------------------------------------------
# Environment Configuration
# ----------------------------------------------------------------------------
# Environment name determines deployment tier and configuration
# Example values: "dev", "test", "staging", "production"
variable "environment" {
  type        = string
  description = "Environment name for the deployment (dev, test, staging, production)"
  
  # Note: Validation blocks are NOT supported in Terraform Stacks variables
  # To add validation, implement checks in your component modules instead
}

# ----------------------------------------------------------------------------
# Pet Configuration
# ----------------------------------------------------------------------------
# Configures the random_pet resource generation

variable "pet_prefix" {
  type        = string
  description = "Prefix for the random pet name (e.g., 'demo', 'test', 'prod')"
  default     = "demo"
}

variable "pet_length" {
  type        = number
  description = "Number of words in the random pet name (1-3 recommended)"
  default     = 3
}

# ----------------------------------------------------------------------------
# Null Resource Configuration
# ----------------------------------------------------------------------------
# Configures null_resource behavior for lifecycle demonstrations

variable "null_resource_count" {
  type        = number
  description = "Number of null resources to create for demonstrating count and for_each patterns"
  default     = 2
}

variable "enable_nulls" {
  type        = bool
  description = "Feature flag to enable/disable null resource creation (demonstrates conditional components)"
  default     = true
}

# ----------------------------------------------------------------------------
# Tagging and Metadata
# ----------------------------------------------------------------------------
# Demonstrates tag propagation and metadata management

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to resources that support tagging"
  default     = {}
}

variable "project_name" {
  type        = string
  description = "Project name for tagging and naming conventions"
  default     = "terraform-stacks-demo"
}

variable "owner" {
  type        = string
  description = "Owner of the infrastructure for tracking and notifications"
  default     = "platform-engineering"
}

# ----------------------------------------------------------------------------
# Advanced Patterns
# ----------------------------------------------------------------------------
# These variables demonstrate advanced Stack patterns

variable "deployment_metadata" {
  type = object({
    team           = string
    cost_center    = string
    compliance     = string
    backup_policy  = string
  })
  description = "Complex object demonstrating structured metadata passing"
  default = {
    team           = "platform"
    cost_center    = "engineering"
    compliance     = "internal"
    backup_policy  = "standard"
  }
}

# ----------------------------------------------------------------------------
# OPTIONAL: Store Integration (Ephemeral Variables)
# ----------------------------------------------------------------------------
# Uncomment to demonstrate HCP Terraform Variable Sets via store blocks
# Remember: Values from store blocks are ephemeral and require ephemeral = true

# variable "hcp_project_id" {
#   type        = string
#   description = "HCP Project ID from variable set"
#   ephemeral   = true
#   sensitive   = true
# }

# variable "notification_webhook" {
#   type        = string
#   description = "Webhook URL for deployment notifications from variable set"
#   ephemeral   = true
#   sensitive   = true
# }

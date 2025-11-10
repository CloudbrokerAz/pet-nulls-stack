# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
      version = "3.1.1"
    }
  }
}

variable "pet" {
  type        = string
  description = "Pet name from upstream component (creates dependency)"
}

variable "instances" {
  type        = number
  description = "Number of null_resource instances to create"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply (stored in triggers for demonstration)"
  default     = {}
}

resource "null_resource" "this" {
  count = var.instances

  triggers = {
    pet             = var.pet
    instance_number = count.index
    timestamp       = timestamp()
    # Store tags as JSON in triggers to demonstrate lifecycle
    tags_json       = jsonencode(var.tags)
  }
}

output "ids" {
  description = "List of null_resource IDs"
  value       = [for n in null_resource.this : n.id]
}

output "count" {
  description = "Number of null_resources created"
  value       = length(null_resource.this)
}

output "triggers" {
  description = "Trigger values that cause recreation"
  value = {
    pet = var.pet
    count = var.instances
  }
}

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.3.2"
    }
  }
}

variable "prefix" {
  type        = string
  description = "Prefix for the random pet name"
}

variable "length" {
  type        = number
  description = "Number of words in the pet name"
  default     = 3
}

resource "random_pet" "this" {
  prefix = var.prefix
  length = var.length
}

output "name" {
  description = "The full pet name (prefix + random words)"
  value       = random_pet.this.id
}

output "id" {
  description = "The unique ID of the random_pet resource"
  value       = random_pet.this.id
}

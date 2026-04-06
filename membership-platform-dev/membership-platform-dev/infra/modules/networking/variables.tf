variable "resource_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr = string

    # Set to "Enabled" on subnets that host private endpoints so NSG rules apply to them.
    # Defaults to "Disabled" (Azure default).
    private_endpoint_network_policies = optional(string, "Disabled")

    delegation = optional(object({
      name    = string
      service = string
      actions = list(string)
    }))
  }))
}

variable "tags" {
  type = map(string)
}

variable "apim_subnet_name" {
  type    = string
  default = "snet-apim"
}

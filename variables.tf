variable "ansiblenode_location" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "ansiblenode_address_space" {
  default     = ["1.0.0.0/16"]
}

#variable for network range

variable "ansiblenode_address_prefix" {
  default = "1.0.1.0/24"
}

#variable for Environment
variable "Environment" {
  type = string
}

variable "ansiblenode_count" {
  type = number
}




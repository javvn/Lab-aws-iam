variable "env" {
  type        = string
  default     = "dev"
  description = "Environment"
}

variable "groups" {
  type        = list(string)
  description = "The name of group to create"
}

variable "users" {
  type = list(object({
    Name  = string
    Group = string
    Role  = string
  }))
  description = "The list of user to create"
}
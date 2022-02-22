variable "application_path_prefix" {
  type        = string
  description = "Prefix path (if app is not hosted at the root)"
}

 variable "website_source_directory" {
   type = string
   description = "Location of minified src (usually the npm build dir)"
 }

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region"
}

variable "environment" {
  type        = string
  default     = "sandbox"
  description = "Environment name"
}

variable "application_name" {
  type        = string
  description = "Name of the application"
}

variable "bucket_prefix" {
  type        = string
  default     = ""
  description = "Bucket Prefix"
}
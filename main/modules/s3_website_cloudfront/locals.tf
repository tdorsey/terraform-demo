locals {
  application_path = "${var.application_path_prefix}/${var.application_name}"
}

locals {
    s3_origin_id = "${local.application_path}"

}
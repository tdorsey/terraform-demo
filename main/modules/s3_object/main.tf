# module "s3_directory_upload" {
#   source                   = "./modules/s3_directory_upload.tf"
#   application_name         = "app1"
#   environment              = "sandbox"
#   application_path_prefix  = ""
#   website_source_directory = "../${path.module}/website/build"
# }



resource "aws_s3_object" "object" {
    for_each = fileset(abspath("../${path.module}/website/build"), "**/*")

  key        = each.key
  bucket = aws_s3_bucket.website_bucket.id
  source     = abspath(each.value)


}

module "upload_files" {
  source                   = "./modules/s3_object"
  bucket                   = var.bucket
  website_source_directory = "../${path.module}/website/build"
}
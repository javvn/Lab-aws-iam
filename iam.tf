################################################
# IAM USER
################################################
resource "aws_iam_user" "this" {
  ######################################
  # permissions_boundary = ""
  ######################################
  count = length(var.users)

  name          = var.users[count.index].Name
  path          = "/${var.users[count.index].Group}/"
  force_destroy = true


  tags = merge(local.common_tags, {
    Name  = var.users[count.index].Name
    Group = var.users[count.index].Group
    Role  = var.users[count.index].Role
  })
}

################################################
# IAM ACCESS KEY
################################################
resource "aws_iam_access_key" "this" {
  ######################################
  # pgp_key = ""
  ######################################
  count = length(var.users)

  user   = var.users[count.index].Name
  status = "Active"


  depends_on = [
    aws_iam_user.this
  ]
}

################################################
# IAM USER LOGIN PROFILE
################################################
resource "aws_iam_user_login_profile" "this" {
  ################################################
  # pgp_key = ""
  # password_length = 20
  ################################################
  count = length(var.users)

  user                    = var.users[count.index].Name
  password_reset_required = true

  depends_on = [
    aws_iam_user.this
  ]
}

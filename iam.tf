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

################################################
# IAM GROUP
################################################
resource "aws_iam_group" "this" {
  count = length(var.groups)

  name = var.groups[count.index]
}

################################################
# IAM GROUP MEMBERSHIP
################################################
resource "aws_iam_group_membership" "this" {
  count = length(aws_iam_group.this)

  group = aws_iam_group.this[count.index].name
  name  = "${aws_iam_group.this[count.index].name}-group-membership"
  users = [for k, v in aws_iam_user.this : v.name if v.tags.Group == aws_iam_group.this[count.index].name]

  depends_on = [
    aws_iam_user.this,
    aws_iam_group.this
  ]
}
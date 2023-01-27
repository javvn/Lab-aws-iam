locals {
  common_tags = {
    Env       = var.env
    Terraform = true
  }

  user_profiles = { for k, v in aws_iam_user.this : v.name => {
    arn         = v.arn
    role        = v.tags.Role
    path        = v.path
    status      = aws_iam_access_key.this[k].status
    create_data = aws_iam_access_key.this[k].create_date
    password    = aws_iam_user_login_profile.this[k].password
  } }

  groups = { for k, v in aws_iam_group.this : v.name => {
    arn   = v.arn
    users = tolist(aws_iam_group_membership.this[k].users)
  } }
}
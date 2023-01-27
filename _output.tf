//output "admin_policy_arn" {
//  value = data.aws_iam_policy.admin.arn
//}
//


output "user_profile" {
  value = { for k, v in var.users : v["Name"] => {
    Path        = aws_iam_user.this[k].path
    Status      = aws_iam_access_key.this[k].status
    Create_data = aws_iam_access_key.this[k].create_date
    Password    = aws_iam_user_login_profile.this[k].password
  } }
}

output "groups" {
  value = { for k, v in aws_iam_group.this : v.name => {
    arn   = v.arn
    users = tolist(aws_iam_group_membership.this[k].users)
  } }
}

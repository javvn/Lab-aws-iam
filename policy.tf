data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

########################################################
# POLICY - BASIC ACCESS FOR DEV
########################################################
resource "aws_iam_policy" "dev" {
  name        = "DevBasicAccess"
  path        = "/dev/"
  description = "Provides only read IAM resource"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:ChangePassword",
        ],
        Resource = "*"
      },
    ]
  })

  tags = local.common_tags
}

########################################################
# GROUP POLICY ATTACHMENT
########################################################
resource "aws_iam_group_policy_attachment" "this" {
  for_each = local.groups

  group      = each.key
  policy_arn = each.key == "admin" ? data.aws_iam_policy.admin.arn : aws_iam_policy.dev.arn

  depends_on = [
    aws_iam_group.this,
    aws_iam_group_membership.this,
    aws_iam_policy.dev,
  ]
}


//########################################################
//# POLICY - IAM FULL FOR LEADER OR ADMIN OR ROOT
//########################################################
////resource "aws_iam_policy" "iam_full" {
////  name = "LabIAMFull"
////  description = "IAM full access policy for leader or admin or root"
////
////  policy = jsonencode({
////    "Version": "2012-10-17",
////    "Statement": [
////      {
////        "Effect": "Allow",
////        "Action": "iam:*"
////        "Resource": "*"
////      }
////    ]
////  })
////
////  tags = local.common_tags
////
////  depends_on = [
////    aws_iam_user.user
////  ]
////}
//
//########################################################
//# POLICY - IAM FULL FOR LEADER OR ADMIN OR ROOT
//########################################################
//resource "aws_iam_policy" "code_commit_full" {
//  name        = "Lab-CodeCommitFullAccess"
//  description = "Code commit full access policy"
//
//  policy = jsonencode({
//    "Version" : "2012-10-17",
//    "Statement" : [
//      {
//        "Effect" : "Allow",
//        "Action" : ["codecommit:ListRepositories"],
//        "Resource" : "*"
//      },
//      {
//        "Effect" : "Allow",
//        "Action" : ["codecommit:GetRepository"],
//        "Resource" : local.repo_state["arn"]
//      }
//    ]
//  })
//
//  tags = local.common_tags
//
//  depends_on = [
//    data.terraform_remote_state.repository
//  ]
//}
//
//########################################################
//# POLICY GROUP ATTACHMENT
//########################################################
//resource "aws_iam_group_policy_attachment" "this" {
//  group      = aws_iam_group.dev.name
//  policy_arn = aws_iam_policy.code_commit_full.arn
//
//  depends_on = [
//    aws_iam_group.dev,
//    aws_iam_policy.code_commit_full
//  ]
//}
//
//########################################################
//# POLICY USER ATTACHMENT
//########################################################
//resource "aws_iam_user_policy_attachment" "this" {
//  user       = "john"
//  policy_arn = aws_iam_policy.code_commit_full.arn
//
//  depends_on = [
//    aws_iam_user.user,
//    aws_iam_policy.code_commit_full
//  ]
//}

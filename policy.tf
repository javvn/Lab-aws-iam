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

########################################################
# POLICY -  FOR LEADER
########################################################
resource "aws_iam_policy" "dev_leader" {
  name        = "DevLeaderAccess"
  path        = "/dev/"
  description = "Provides code commit full access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "codecommit:*",
        "Resource" : "*"
      }
    ]
  })

  tags = local.common_tags
}

########################################################
# POLICY -  FOR MEMBER
########################################################
resource "aws_iam_policy" "dev_member" {
  name        = "DevMemberAccess"
  path        = "/dev/"
  description = "Provides code commit limited access"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Action : [
        "codecommit:*Branch",
        "codecommit:*Comment",
        "codecommit:Get*",
        "codecommit:List*",
        "codecommit:PutFile",

      ],
      Resource : "*"
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role" "this" {
  count = length(var.roles)

  path = "/dev/"
  name = "Dev${title(var.roles[count.index])}"


  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      "Effect" : "Allow",
      "Action" : "sts:AssumeRole"
      "Principal" : {
        "AWS" : var.roles[count.index] == "leader" ? local.leader_users.arn : local.member_users.arn
      },
    }]
  })

  managed_policy_arns = var.roles[count.index] == "leader" ? [
    data.aws_iam_policy.admin.arn,
    aws_iam_policy.dev_leader.arn
    ] : [
    aws_iam_policy.dev.arn,
    aws_iam_policy.dev_member.arn
  ]

  depends_on = [
    aws_iam_policy.dev,
    aws_iam_policy.dev_leader,
    aws_iam_policy.dev_member,
    aws_iam_user.this,
    aws_iam_group.this
  ]

  tags = merge(local.common_tags, { Role = title(var.roles[count.index]) })
}


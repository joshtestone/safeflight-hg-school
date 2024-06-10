locals {
  tags = {
    Terraform = "true"
    Workspace = "s3://457661787930-terraform-backend/terraform/aws/account/iam/atlantis_deployer/${terraform.workspace}"
  }
}

####################
# APPLY THIS TO ALL AWS ACCOUNTS WHERE ATLANTIS DEPLOYS TO #
####################
data "aws_iam_policy_document" "atlantis_deployer_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = ["*"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = [
        "arn:aws:iam::${var.atlantis_account_id}:role/*-atlantis-manager",
        # Your personal user if needed. Comment out if not needed and remove comma from line above.
        "arn:aws:iam::${var.atlantis_account_id}:user/demo"
      ]
    }
  }
}

resource "aws_iam_role" "atlantis_deployer" {
  name               = "${var.account_id}-atlantis-deployer"
  assume_role_policy = data.aws_iam_policy_document.atlantis_deployer_assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "atlantis_deployer_attach_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.atlantis_deployer.name
}

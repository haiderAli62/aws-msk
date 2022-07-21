data "aws_caller_identity" "current" {}

variable "ENV" {
    default = "dev"
}

variable "CURRENT_ACCOUNT_ID" {
    default =  "${data.aws_caller_identity.current.account_id}"
}
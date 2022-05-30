alias k='kubectl'
alias tf='terraform -chdir=./tf'

box_id() {
  local num="$1"
  tf output -raw "kube${num}-id"
}

ssm() {
  local num="$1"
  shift
  aws ssm start-session --target "$(box_id "$num")" "$@"
}

logs() {
  local num="$1"
  shift
  aws ec2 get-console-output --instance-id "$(box_id "$num")" --output text "$@"
}

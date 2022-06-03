#!/bin/bash

# This script requires
# - terraform
# - jq
# - yq
# - aws cli
# - kubectl
# - AWS credentials with a ton of permissions

alias k='kubectl'

tf-select() {
  local opts="cluster app"
  local proj=$(\grep -o "\b$1\w*\b" <<<"$opts")
  if [ "$(wc -w <<<"$proj")" -ne 1 ]; then
    >&2 echo "Valid options are \"$opts\""
    return 1
  fi

  set -x
  alias tf="terraform -chdir=./tf/$proj"
  { set +x; } 2>/dev/null
}

box_id() {
  local num="$1"
  terraform -chdir=./tf/cluster output -raw "kube${num}-id"
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

ssm-command() {
  local id=$(box_id 1)
  local res=$(aws ssm send-command \
    --instance-ids "$id" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=$*")
  local cmd_id=$(<<<"$res" jq '.Command.CommandId' -r)
  while : ; do
    local inv=$(aws ssm get-command-invocation --command-id "$cmd_id" --instance-id "$id")
    [ "$(<<<"$inv" jq '.Status' -r)" == "InProgress" ] || break
  done
  printf 'Status: %s\n' "$(<<<"$inv" jq '.Status' -r)"
  <<<"$inv" jq '.StandardErrorContent' -r
  <<<"$inv" jq '.StandardOutputContent' -r
  return $(<<<"$inv" jq '.ResponseCode' -r)
}

ssm-kubeconf() {
  local ip=$(terraform -chdir=./tf/cluster output -raw "kube1-ip")
  local conf=$(ssm-command "kubectl config view --raw")
  if [ -z "$conf" ]; then
    >&2 echo "Empty conf $conf"
    return
  fi

  local ca=$(<<<"$conf" yq '.clusters[0].cluster["certificate-authority-data"]')
  local server="https://$ip:6443"
  kubectl config set-cluster todo-kubernetes \
    --server "$server" \
    --embed-certs \
    --certificate-authority <(base64 -d <<<"$ca")

  local cert=$(<<<"$conf" yq '.users[0].user["client-certificate-data"]')
  local key=$(<<<"$conf" yq '.users[0].user["client-key-data"]')
  kubectl config set-credentials todo-kubernetes \
    --embed-certs \
    --client-certificate <(base64 -d <<<"$cert") \
    --client-key <(base64 -d <<<"$key")

  kubectl config set-context todo-kubernetes \
    --cluster todo-kubernetes \
    --user todo-kubernetes

  kubectl config get-contexts
}

kuse() {
  kubectl config use todo-kubernetes
}

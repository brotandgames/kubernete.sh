#!/usr/bin/env bash
set -eo pipefail
shopt -s nullglob

# CLI variables
cli_name=${0##*/}
cli_command=$1
cli_version="v0.1.2"
cli_dependencies=terraform,kubectl

# Check CLI dependencies
for d in $(echo $cli_dependencies | tr "," "\n"); do
  command -v $d >/dev/null 2>&1 || { echo >&2 "$cli_name requires $d but it's not installed. Please install $d and try again."; exit 1; }
done

# CLI helper functions
cli_log() {
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "== $cli_name $timestamp $1"
}

cli_help() {
  echo "$cli_name
https://github.com/brotandgames/kubernete.sh

Usage: $cli_name [command]

Commands:
  deploy       Deploy a Kubernetes Cluster
  token        Get Kubernetes Dashboard Token <sensitive>
  proxy        Creates a proxy between localhost and the Kubernetes API Server
  print_nodes  Print node configuration in HCL (for Debugging)
  version      Print version
  *            Help
"
  exit 1
}

cli_help_deploy() {
  echo "Command: 
  $cli_name deploy

Usage: 
  $cli_name deploy user@node1[,user@node2,user@nodeN] [ssh_private_key_path]

Examples:
  $cli_name deploy root@n1.kubernete.sh
  $cli_name deploy root@n1.kubernete.sh,root@n2.kubernete.sh ~/.ssh/id_rsa"
  exit 1
}

# Commands
print_nodes() {
  local nodes=$(echo $1 | tr "," "\n")
  local ssh_private_key_path=${2:-~/.ssh/id_rsa}
  for n in $nodes; do 
    echo "
  nodes {
    address = \"$(echo $n | cut -d @ -f2)\"
    user    = \"$(echo $n | cut -d @ -f1)\"
    role    = [\"controlplane\", \"worker\", \"etcd\"]
    ssh_key = \"\${file(\"$ssh_private_key_path\")}\"
  }"
  done
}

deploy() {
  [ -z "$1" ] && cli_log "ERROR: No nodes argument found." \
              && cli_help_deploy
  cli_log "INFO Starting deployment to $1"
  cat > kubernete.tf <<-EOF
resource rke_cluster "cluster" {
  $(print_nodes $1 $2)

  addons_include = [
  "https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml",
  "https://gist.githubusercontent.com/superseb/499f2caa2637c404af41cfb7e5f4a938/raw/930841ac00653fdff8beca61dab9a20bb8983782/k8s-dashboard-user.yml",
  ]
}

resource "local_file" "kube_cluster_yaml" {
  filename = "\${path.root}/kube_config_cluster.yml"
  sensitive_content  = "\${rke_cluster.cluster.kube_config_yaml}"
}
EOF

  terraform init && terraform apply && cli_log "INFO Deployed Kubernetes successfully to $1"
}

token() {
  echo "Token:"
  kubectl --kubeconfig kube_config_cluster.yml -n kube-system describe secret $(kubectl --kubeconfig kube_config_cluster.yml -n kube-system get secret | grep admin-user | awk '{print $1}') | grep ^token: | awk '{ print $2 }'
}

proxy() {
  echo "Visit: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
  kubectl --kubeconfig kube_config_cluster.yml proxy
}

# Main
case "$cli_command" in
  deploy|d)
    deploy $2 $3
    ;;
  token|t)
    token
    ;;
  proxy|p)
    proxy
    ;;
  print_nodes|pn)
    print_nodes $2 $3
    ;;
  version|v)
    echo "$cli_name $cli_version"
    ;;
  *)
    cli_help
    ;;
esac

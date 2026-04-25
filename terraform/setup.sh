#!/bin/bash
set -e

echo "==> Initializing Terraform..."
terraform init

echo "==> Applying Terraform..."
terraform apply

KEY_FILE="$HOME/.ssh/tprep_deploy"
IP=$(terraform output -raw external_ip)

echo "==> Saving SSH key to $KEY_FILE"
terraform output -raw ssh_private_key > "$KEY_FILE"
chmod 600 "$KEY_FILE"

echo "==> Server IP: $IP"
echo "==> Waiting for server to be ready..."
until ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@"$IP" "echo ok" 2>/dev/null; do
  sleep 5
done

echo "==> Connecting..."
ssh -i "$KEY_FILE" -o StrictHostKeyChecking=no ubuntu@"$IP"
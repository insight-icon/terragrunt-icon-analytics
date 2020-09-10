#!/usr/bin/env bash
public_ip=$(terragrunt output -json | jq -r .public_ip.value)
echo $public_ip
mkdir -p ./dags
sudo mount -t nfs -o vers=4 -o tcp -w ${public_ip}:/ ./dags
sudo chown $UID:$GID ./dags

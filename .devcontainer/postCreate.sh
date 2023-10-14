#!/bin/bash

sudo apt-get update

# install package to resolve hostname.localhost addresses
# sudo apt-get install libnss-myhostname
echo "127.0.0.1 k3d-registry.localhost" | sudo tee -a /etc/hosts

# install k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/v5.6.0/install.sh | TAG=v5.6.0 bash

#!/bin/bash

sudo apt-get update

# install package to resolve hostname.localhost addresses
sudo apt-get install libnss-myhostname

# install k3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/v5.6.0/install.sh | AG=v5.6.0 bash

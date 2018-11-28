#!/bin/bash
set -o errexit

cd /tmp
curl -sL https://github.com/sstephenson/bats/archive/master.zip > bats.zip 
unzip -q bats.zip 
./bats-master/install.sh /usr/local 
ln -sf /usr/local/libexec/bats /usr/local/bin/bats 
rm -rf bats* 
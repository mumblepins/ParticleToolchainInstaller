#!/bin/bash

# From here:
# http://askubuntu.com/questions/293838/shell-script-to-conditionally-add-apt-repository

add_ppa() {
  grep -h "^deb.*$1" /etc/apt/sources.list.d/* > /dev/null 2>&1
  if [ $? -ne 0 ]
  then
    echo "Adding ppa:$1"
    sudo add-apt-repository -y ppa:$1
    return 0
  fi

  echo "ppa:$1 already exists"
  return 1
}

add_ppa terry.guo/gcc-arm-embedded
apt-get update
apt-get -y install gcc-arm-none-eabi git

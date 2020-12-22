#!/bin/bash
# Install Storj NOde
# V0.1 18/12/2020
if $(uname -m | grep '64'); then
  echo "ARCH: 64-bit"
  $ARCH = "64";
else
  echo "ARCH: 32-bit"
  $ARCH = "32";
fi
#Detect memory size
$totalm=$(free -m | awk '/^Mem:/{print $2}') ;

echo "Storj node installer"
echo "1° - Raspberry PI update...."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo rpi-update

if ($totalm > 4000);then
  echo "Disable Swap file on SDCARD"
  sudo dphys-swapfile swapoff
  sudo dphys-swapfile uninstall
  sudo update-rc.d dphys-swapfile remove
  sudo apt purge dphys-swapfile
fi

echo ""
echo "2° - create Storj node directory"
sudo mkdir /mnt/storagenode
sudo chown -R pi:pi /mnt/storagenode
sudo chmod -R 775 /mnt/storagenode

echo ""
echo "3° - Download identity manager"
if ($ARCH == "64");then
  curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_arm64.zip -o identity_linux_arm64.zip
  unzip -o identity_linux_arm64.zip
else
  curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_arm.zip -o identity_linux_arm.zip
  unzip -o identity_linux_arm.zip
fi
chmod +x identity
sudo mv identity /usr/local/bin/identity

echo ""
echo "4° - Docker"
echo "4°1 - prepare..."
sudo echo "cgroup_enable=memory cgroup_memory=1 swapaccount=1" >> /boot/cmdline.txt
echo "4°2 - Download....."
curl -sSL https://get.docker.com | sudo sh

echo "4°3 - Download Storj docker file"
sudo docker pull storjlabs/storagenode:beta

echo "4°4 - Download Storj Watcher update"
sudo docker pull storjlabs/watchtower
sudo docker run -d --restart=always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock storjlabs/watchtower storagenode watchtower --stop-timeout 300s --interval 21600

echo "5° - Install storj-exporrter"
docker run -d --link=storagenode --name=storj-exporter -p 9651:9651 anclrii/storj-exporter:latest

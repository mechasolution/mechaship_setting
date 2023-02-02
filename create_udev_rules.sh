#!/bin/bash

echo ""
echo "This script copies udev rules to /etc/udev/rules.d/"
echo ""

echo "MCU : /dev/ttyTHS1 to /dev/ttyMCU :"
if [ -f "/etc/udev/rules.d/98-mechaship-mcu" ]; then
    echo "98-mechaship-mcu file already exist."
else 
    echo 'KERNEL=="ttyTHS1", MODE:="0666", GROUP:="dialout", SYMLINK+="ttyMCU"' |  sudo tee /etc/udev/rules.d/98-mechaship-mcu.rules > /dev/null  
    echo '98-mechaship-mcu created'
fi

echo ""
echo "YD LiDAR (USB Serial) : /dev/ttyUSBx to /dev/ttyLiDAR :"
if [ -f "/etc/udev/rules.d/97-mechaship-lidar.rules" ]; then
    echo "97-mechaship-lidar.rules file already exist."
else 
    echo 'KERNEL=="ttyUSB*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE:="0666", GROUP:="dialout",  SYMLINK+="ttyLiDAR"' | sudo tee /etc/udev/rules.d/97-mechaship-lidar.rules > /dev/null
    
    echo '97-mechaship-lidar.rules created'
fi

systemctl stop nvgetty
systemctl disable nvgetty

echo ""
echo "Reload rules"
echo ""
sudo udevadm control --reload-rules
sudo udevadm trigger
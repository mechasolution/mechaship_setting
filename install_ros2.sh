#!/bin/sh

echo "\n################################################################"
echo "Locale 설정 시작"
echo "################################################################"
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "\n################################################################"
echo "ROS2 Repository 추가"
echo "################################################################"
sudo apt install -y curl gnupg2 lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "\n################################################################"
echo "ROS2 Foxy 설치, 적용"
echo "################################################################"
sudo apt update && sudo apt install -y ros-foxy-desktop
bash /opt/ros/foxy/setup.bash
bashrc=$(tail ~/.bashrc)
if [ $(expr "$bashrc" : ".*source /opt/ros/foxy/setup.bash") -ne 0 ]; then
  echo "ros foxy setup.bash 등록 확인"
else
  echo "ros foxy  setup.bash 등록"
  echo "source /opt/ros/foxy/setup.bash" >> ~/.bashrc
fi

echo "\n################################################################"
echo "colcon 빌드툴 및 기타 소프트웨어 설치"
echo "################################################################"
sudo apt install -y python3-pip python3-rosdep2
pip3 install -U argcomplete xacro
pip install setuptools==45.2.0
sudo apt install python3-colcon-common-extensions
bashrc=$(tail ~/.bashrc)
if [ $(expr "$bashrc" : ".*alias cb='cd ~/ros2_ws && colcon build --symlink-install && source ~/ros2_ws/install/local_setup.bash'") -ne 0 ]; then
  echo "단축 명령어 cb 등록 확인"
else
  echo "단축 명령어 cb 등록"
  echo "alias cb='cd ~/ros2_ws && colcon build --symlink-install && source ~/ros2_ws/install/local_setup.bash'" >> ~/.bashrc
fi

echo "\n################################################################"
echo "워크스페이스 설정"
echo "################################################################"
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws
colcon build
bash ~/ros2_ws/install/local_setup.bash
bashrc=$(tail ~/.bashrc)
if [ $(expr "$bashrc" : ".*source ~/ros2_ws/install/setup.bash") -ne 0 ]; then
  echo "워크스페이스 setup.bash 등록 확인"
else
  echo "워크스페이스 setup.bash 등록"
  echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc
fi

echo "\n################################################################"
echo "micro-ros 설치"
echo "################################################################"
cd ~/
mkdir uros_ws && cd uros_ws
git clone -b $ROS_DISTRO https://github.com/micro-ROS/micro_ros_setup.git src/micro_ros_setup
rosdep update && rosdep install --from-paths src --ignore-src -y
colcon build
source install/local_setup.bash
ros2 run micro_ros_setup create_agent_ws.sh
ros2 run micro_ros_setup build_agent.sh
source install/local_setup.sh
bashrc=$(tail ~/.bashrc)
if [ $(expr "$bashrc" : ".*source ~/uros_ws/install/local_setup.bash") -ne 0 ]; then
  echo "uros_ws setup.bash 등록 확인"
else
  echo "uros_ws setup.bash 등록"
  echo "source ~/uros_ws/install/local_setup.bash" >> ~/.bashrc
fi

echo "\n################################################################"
echo "도메인 아이디 및 시리얼 포트 접근 권한 설정"
echo "################################################################"
if [ $ROS_DOMAIN_ID ]; then
  echo "ROS_DOMAIN_ID 등록 확인"
else
  echo "ROS_DOMAIN_ID 등록"
  echo "export ROS_DOMAIN_ID=0" >> ~/.bashrc
fi
sudo adduser $USER dialout

echo "\n################################################################"
echo "udev rules 설정"
echo "################################################################"
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

echo "\n################################################################"
echo "실행 완료"
echo "################################################################"

source ~/.bashrc

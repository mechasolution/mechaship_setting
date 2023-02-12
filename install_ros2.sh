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
sudo apt install -y python3-pip python3-rosdep2 ros-foxy-xacro
pip3 install -U argcomplete
pip install setuptools==45.2.0
sudo apt install -y python3-colcon-common-extensions
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
echo "실행 완료, 터미널을 닫고 다시 열어주세요."
echo "################################################################"

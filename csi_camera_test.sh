#!/bin/sh

echo "\n################################################################"
echo "CSI-Camera 예제 다운로드"
echo "################################################################"
sudo apt install git
cd ~
git clone https://github.com/JetsonHacksNano/CSI-Camera.git

echo "\n################################################################"
echo "CSI-Camera 예제 실행"
echo "################################################################"
cd ~/CSI-Camera
python3 simple_camera.py

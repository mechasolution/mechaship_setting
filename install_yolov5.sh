#!/bin/sh

echo "\n################################################################"
echo "CUDA 설치 확인"
echo "################################################################"
NVCC=$(nvcc --version)
if [ $(expr "$NVCC" : ".*cuda_10.2") -ne 0 ]; then
  echo "cuda 10.2 설치 확인"
else
  echo "cuda 환경 변수 등록"
  echo "export PATH=/usr/local/cuda/bin:\$PATH" >> ~/.bashrc
  echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:/lib64:\$LD_LIBRARY_PATH" >> ~/.bashrc
  echo "export DISPLAY=:0" >> ~/.bashrc
  . ~/.bashrc
  nvcc --version
fi

echo "\n################################################################"
echo "YOLOv5 설치"
echo "################################################################"
sudo apt install git
cd ~
git clone https://github.com/ultralytics/yolov5

echo "\n################################################################"
echo "YOLOv5 의존성 패키지 설치"
echo "################################################################"
pip install pandas==1.1.4
pip install matplotlib==3.2.2
sed -i "s/opencv-python/#opencv-python/" ~/yolov5/requirements.txt
pip install -r ~/yolov5/requirements.txt


echo "\n################################################################"
echo "실행 완료"
echo "################################################################"
echo "Install prerequisites"
sudo apt update
sudo apt install python python-pip -y
pip install requests
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker $USER

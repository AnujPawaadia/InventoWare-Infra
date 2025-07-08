#!/bin/bash
sudo apt-get update -y
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo docker run -d -p 5000:5000 --name app arjuncodeops/inventoware-app:latest

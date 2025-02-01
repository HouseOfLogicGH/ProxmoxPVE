#!/bin/bash
# run these commands from the after cloning and editing the files - same commands in README.md.

sudo apt-get update
sudo apt-get install docker.io
cd pve
sudo docker pull prompve/prometheus-pve-exporter
sudo docker run --init --name prometheus-pve-exporter -d -p 0.0.0.0:9221:9221 -v /home/user/pve/pve.yml:/etc/prometheus/pve.yml prompve/prometheus-pve-exporter
sudo docker ps
curl localhost:9221
cd ../prometheus
sudo docker volume create prometheus-data
sudo docker run --name prometheus \
    -p 9090:9090 \
    -d \
    -v /home/user/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v prometheus-data:/prometheus \
    prom/prometheus

cd ../grafana
sudo docker volume create grafana-storage

sudo docker run -d -p 3000:3000 --name=grafana \
  --volume grafana-storage:/var/lib/grafana \
  grafana/grafana-enterprise


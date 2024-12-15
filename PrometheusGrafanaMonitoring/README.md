# Monitoring Proxmox with Prometheus and Grafana

## Instructions

### User Setup
Create user with full read permission in GUI.
 Assign user to datacenter root ( "/" ) as PVEadmin.
Or create token and do the same thing.

### Clone Repo

Clone this repo and edit the files from the PrometheusGrafanaMonitoring directory as appropriate for the correct Proxmox IP, node name and Docker host IP address.

### Install docker on a host of your choice
apt-get update
apt-get install docker.io

The Proxmox Virtualisation Environment Exporter is found here https://github.com/prometheus-pve/prometheus-pve-exporter
Create config for pve exporter using nano

mkdir pve
cd pve

Add the content from the pve.yml file and edit as appropriate

nano pve.yml

### Install prometheus proxmox exporter using docker (running as daemon)
sudo docker pull prompve/prometheus-pve-exporter
sudo docker run --init --name prometheus-pve-exporter -d -p 0.0.0.0:9221:9221 -v /home/user/pve/pve.yml:/etc/prometheus/pve.yml prompve/prometheus-pve-exporter

Check the exporter is running using 

sudo docker ps
curl localhost:9221

Use browser to inspect metrics, eg http://192.168.2.11:9221/pve?target=192.168.2.10


### Configure Prometheus using nano 

cd ..
mkdir prometheus
nano prometheus.yml

Copy contents of prometheus.yml into file and edit as appropriate.

### Install prometheus using docker

Create persistent volume for your data

sudo docker volume create prometheus-data

Start Prometheus container
sudo docker run \
    -p 9090:9090 \
    -d \
    -v /home/user/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    -v prometheus-data:/prometheus \
    prom/prometheus

Test prometheus metrics
Browse to docker host ip prometheus port eg http://192.168.2.11:9090

### Configure grafana using nano

cd ..
mkdir grafana
cd grafana

# Create storage for docker
sudo docker volume create grafana-storage

# Start grafana
sudo docker run -d -p 3000:3000 --name=grafana \
  --volume grafana-storage:/var/lib/grafana \
  grafana/grafana-enterprise

Login to grafana using browser to connect to Grafana port 3000, eg http://192.168.2.11:3000
Default credentials
username = admin
password = admin 

### Create dashboard in grafana using UI

Custom label
{{id}}

Useful links:
https://github.com/prometheus-pve/prometheus-pve-exporter
https://prometheus.io/docs/prometheus/latest/installation/#using-docker
https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/#run-grafana-docker-image

 

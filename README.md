# K-ONE-M-CORD-Monitoring

Note that
* containers of M-CORD Lite are implemented by [K-ONE M-CORD Lite](https://github.com/K-OpenNet/K-ONE-M-CORD-Lite)
* influxDB container for time-series database and Grafana container for dashboard are used
* Scapy for monitoring network traffic statistics 
* monitor contianer and shell scripts are implemented by Jibum Hong @ POSTECH


## Specification
* OS: Ubuntu 16.04 and 18.04
* Docker version 18.09.7
* Prometheus version 1.7.0
* Grafana version 4.4.5
* InfluxDB version 1.7.9
* Scapy version 2.3.3


## Preliminaries

### 1. Need to install Docker engine
```
node$ ./set_env.sh
```

**NOTE: To make sure that the user is in the `docker` group, please log off and then log in again. You can check which groups belong to the user with the below command.**

```
node$ groups
```
If you can see the group `docker`, everything looks good!

**NOTE: If you install [K-ONE M-CORD Lite](https://github.com/K-OpenNet/K-ONE-M-CORD-Lite), you don't need to this process.**


## Install

### 1. Download and run node-exporter and cAdvisor
```
node$ ./set_each_node.sh
```
* cAdvisor for container resource usage monitoring
* node-exporter for PM resource usage monitoring 


### 2. Configure prometheus configuration files
* Go to `conf/prometheus.yml` and change `<IP_number>` to node IP addresses running node-exporter
* Go to `conf/prometheus-cadvisor.yml` and change `<IP_number>` to node IP addresses running cAdvisor
* Go to `conf/prometheus-collectd.yml` and change `<IP_number>` to node IP addresses running collectd

### 3. Download and run Prometheus for node-exporter and cAdvisor
```
node$ ./set_prom.sh
```
The role of InfluxDB was replaced to Prometheus TSDB for compatibility.


### 4. Download and run Grafana
```
node$ ./set_grafana.sh
```

you can access to grafana web dashboard `<IP_number>:3000`

**initial id : admin / pw : pass**

* Go to "Settings -> Data sources", and Add data sources for node-exporter, cadvisor, and collectd

```
Name: prom-cadvisor / prom-exporter / prom-collectd
URL: http://prometheus-cadvisor:9090 / http://prometheus:9090 / http://prometheus-collectd:9090
Scrape interval: 1s
HTTP Method: GET
```

* Go to "Create -> Import", and paste node-exporter.json and cadvisor.json

## Release information
* Release 1 - Monitoring system resource metrics of each containers in EPC
* Release 2 - Monitoring network statistics of internal link in EPC
* Release 3 - Anomaly Detection using Monitoring System (TBD)

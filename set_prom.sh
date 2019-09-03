
docker run -d -p 19090:9090 --name prometheus -h prometheus -v $(pwd)/config/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:v1.7.0 -config.file=/etc/prometheus/prometheus.yml

docker run -d -p 29090:9090 --name prometheus-cadvisor -h prometheus-cadvisor -v $(pwd)/config/prometheus-cadvisor.yml:/etc/prometheus/prometheus.yml prom/prometheus:v1.7.0 -config.file=/etc/prometheus/prometheus.yml


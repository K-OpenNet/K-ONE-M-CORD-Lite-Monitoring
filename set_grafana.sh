docker run -d --name grafana -h grafana -e GF_SECURITY_ADMIN_PASSWORD=pass -p 3000:3000 --link prometheus:prometheus --link prometheus-cadvisor:prometheus-cadvisor grafana/grafana:4.4.3


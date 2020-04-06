#!/bin/bash
#
# Copyright 2019-present an Individual Developer Woojoong Kim
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

docker run -d -p 19090:9090 --name prometheus -h prometheus -v $(pwd)/config/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus:v2.16.0 --config.file=/etc/prometheus/prometheus.yml

docker run -d -p 29090:9090 --name prometheus-cadvisor -h prometheus-cadvisor -v $(pwd)/config/prometheus-cadvisor.yml:/etc/prometheus/prometheus.yml prom/prometheus:v2.16.0 --config.file=/etc/prometheus/prometheus.yml

docker run -d -p 39090:9090 --name prometheus-collectd -h prometheus-collectd -v $(pwd)/config/prometheus-collectd.yml:/etc/prometheus/prometheus.yml prom/prometheus:v2.16.0 --config.file=/etc/prometheus/prometheus.yml

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

docker run -d --name grafana -h grafana -e GF_SECURITY_ADMIN_PASSWORD=pass -p 3000:3000 --link prometheus:prometheus --link prometheus-cadvisor:prometheus-cadvisor --link prometheus-collectd:prometheus-collectd grafana/grafana:6.6.2

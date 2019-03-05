#!/bin/bash

get_unixtime(){
	local timestamp=$( cat $1 | jq '.timestamp' )
	local timestamp=$( awk -F\" '{print $2}' <<<"$timestamp" )
	local date=$( awk -FT '{print $1}' <<<"$timestamp" )
	local time=$( awk -FT '{print $2}' <<<"$timestamp" )
	local hms=$( awk -F. '{print $1}' <<<"$time")
	local extra=$( awk -F. '{print $2}' <<<"$time")
	local refined_time=$date
	local refined_time+=' '
	local refined_time+=$hms
	local unixtime=$(date +%s -d "$refined_time")
	local unixtime+="000000000"
	
	echo $unixtime
}

push_cpu_data(){
        local cpu_total=$( cat $1 | jq '.cpu.usage.total' )
	local cpu_total_body="cpu_total,container=$3 value=$cpu_total $2"
	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$cpu_total_body"

	local per_cpu_length=$( cat $1 | jq '.cpu.usage.per_cpu_usage' | jq length )        
	for ((i=0;i<$per_cpu_length;i++)); do
		local per_cpu=$( cat $1 | jq ".cpu.usage.per_cpu_usage[$i]" )
		local per_cpu_body="per_cpu,container=$3,cpu_index=$i value=$per_cpu $2"
		curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$per_cpu_body"
	done

	local user_usage=$( cat $1 | jq '.cpu.usage.user' )
        local system_usage=$( cat $1 | jq '.cpu.usage.system' )
        local user_usage_body="user_usage,container=$3 value=$user_usage $2"
        local system_usage_body="system_usage,container=$3 value=$system_usage $2"
        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$user_usage_body"
        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$system_usage_body"
}

push_mem_data(){
        local mem_usage=$( cat $1 | jq '.memory.usage' )
        local mem_max_usage=$( cat $1 | jq '.memory.max_usage' )
	local mem_workingset=$( cat $1 | jq '.memory.working_set' )
	#mem_limit
	
        local mem_usage_body="mem_usage,container=$3 value=$mem_usage $2"
        local mem_max_usage_body="mem_max_usage,container=$3 value=$mem_max_usage $2"
	local mem_workingset_body="mem_workingset,container=$3 value=$mem_workingset $2"

        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$mem_usage_body"
        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$mem_max_usage_body"	
	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$mem_workingset_body"
}

#push_diskio


push_fs_data(){
	local fs_length=$( cat $1 | jq '.filesystem' | jq length )

	for ((i=0;i<fs_length;i++)); do
		local device=$( cat $1 | jq ".filesystem[$i].device" )
        	local fs_capacity=$( cat $1 | jq ".filesystem[$i].capacity" )
        	local fs_usage=$( cat $1 | jq ".filesystem[$i].usage" )

		local fs_capacity_body="fs_capacity,container=$3 value=$fs_capacity $2"
        	local fs_usage_body="fs_usage,container=$3 value=$fs_usage $2"
		
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$fs_capacity_body"
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$fs_usage_body"
	done
}

push_network_data(){
	local iface_length=$( cat $1 | jq '.network' | jq length )

	for ((i=0;i<$iface_length;i++)); do
		local iface=$( cat $1 | jq ".network[$i].name" )
		#local name=$( awk -F\" '{print $2}' <<<"$iface" )
		
		local rx_bytes=$( cat $1 | jq ".network[$i].rx_bytes" )
		local rx_packets=$( cat $1 | jq ".network[$i].rx_packets" )
		local rx_errors=$( cat $1 | jq ".network[$i].rx_errors" )
		local rx_dropped=$( cat $1 | jq ".network[$i].rx_dropped" )
		local tx_bytes=$( cat $1 | jq ".network[$i].tx_bytes" )
		local tx_packets=$( cat $1 | jq ".network[$i].tx_packets" )
		local tx_errors=$( cat $1 | jq ".network[$i].tx_errors" )
		local tx_dropped=$( cat $1 | jq ".network[$i].tx_dropped" )

		local rx_bytes_body="rx_bytes,container=$3,interface=$iface value=$rx_bytes $2"
        	local rx_packets_body="rx_packets,container=$3,interface=$iface value=$rx_packets $2"
        	local rx_errors_body="rx_errors,container=$3,interface=$iface value=$rx_errors $2"
        	local rx_dropped_body="rx_dropped,container=$3,interface=$iface value=$rx_dropped $2"
        	local tx_bytes_body="tx_bytes,container=$3,interface=$iface value=$tx_bytes $2"
        	local tx_packets_body="tx_packets,container=$3,interface=$iface value=$tx_packets $2"
        	local tx_errors_body="tx_errors,container=$3,interface=$iface value=$tx_errors $2"
        	local tx_dropped_body="tx_dropped,container=$3,interface=$iface value=$tx_dropped $2"

		curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$rx_bytes_body"
	        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$rx_packets_body"
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$rx_errors_body"
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$rx_dropped_body"
	        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$tx_bytes_body"
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$tx_packets_body"
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$tx_errors_body"
        	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$tx_dropped_body"
	done
}



push_data(){
	container=$( awk -F. '{print $1}' <<<"$1")
	push_cpu_data "$1" "$2" "$container"
	push_mem_data "$1" "$2" "$container"
	#diskio
        push_fs_data "$1" "$2" "$container"
	push_network_data "$1" "$2" "$container"
}

tmp_cp_stamp=0
tmp_dp_stamp=0
tmp_traffic_stamp=0

for ((;;))
do
	curl -X GET http://141.223.82.62:8080/api/v2.0/stats/cp?type=docker | jq '(."/docker/f15e2c490dac7190c94f85b890cb8fcff901a6eef23f1803345d25b3817ccb4b"| reverse)[0] | {timestamp: .timestamp, cpu: .cpu, memory: .memory, diskio: .diskio.io_service_bytes, filesystem: .filesystem, network: .network.interfaces}' > cp.stats
	curl -X GET http://141.223.82.62:8080/api/v2.0/stats/dp?type=docker | jq '(."/docker/13fc681477ce056812b43a97a5837fcddef94b047d3d746d649ed16dcb276f76"| reverse)[0] | {timestamp: .timestamp, cpu: .cpu, memory: .memory, diskio: .diskio.io_service_bytes, filesystem: .filesystem, network: .network.interfaces}' > dp.stats
	curl -X GET http://141.223.82.62:8080/api/v2.0/stats/traffic?type=docker | jq '(."/docker/4886476c5bc5cf16105ea7a405c1a51a676e47c3175fe6b0cca59e8e17c5f6c2"| reverse)[0] | {timestamp: .timestamp, cpu: .cpu, memory: .memory, diskio: .diskio.io_service_bytes, filesystem: .filesystem, network: .network.interfaces}' > traffic.stats

	cp_timestamp=$( get_unixtime "cp.stats" )	
	if [ $cp_timestamp -ne "$tmp_cp_stamp" ];then
		push_data "cp.stats" "$cp_timestamp"
		tmp_cp_stamp=$cp_timestamp
	fi

	dp_timestamp=$( get_unixtime "dp.stats" )
        if [ $dp_timestamp -ne "$tmp_dp_stamp" ];then
                push_data "dp.stats" "$dp_timestamp"
                tmp_cp_stamp=$dp_timestamp
        fi

	traffic_timestamp=$( get_unixtime "traffic.stats" )
        if [ $traffic_timestamp -ne "$tmp_traffic_stamp" ];then
                push_data "traffic.stats" "$traffic_timestamp"
                tmp_cp_stamp=$traffic_timestamp
        fi

	sleep 1s
done

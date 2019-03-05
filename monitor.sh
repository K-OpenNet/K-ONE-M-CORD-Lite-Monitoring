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
	local cpu_total_body="cpu_total,PM=$PM,container=$3 value=$cpu_total $2"
	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$cpu_total_body"

	local per_cpu_length=$( cat $1 | jq '.cpu.usage.per_cpu_usage' | jq length )        
	for ((i=0;i<$per_cpu_length;i++)); do
		local per_cpu=$( cat $1 | jq ".cpu.usage.per_cpu_usage[$i]" )
		local per_cpu_body="per_cpu,PM=$PM,container=$3,cpu_index=$i value=$per_cpu $2"
		curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$per_cpu_body"
	done

	local user_usage=$( cat $1 | jq '.cpu.usage.user' )
        local system_usage=$( cat $1 | jq '.cpu.usage.system' )
        local user_usage_body="user_usage,PM=$PM,container=$3 value=$user_usage $2"
        local system_usage_body="system_usage,PM=$PM,container=$3 value=$system_usage $2"
        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$user_usage_body"
        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$system_usage_body"
}

push_mem_data(){
        local mem_usage=$( cat $1 | jq '.memory.usage' )
        local mem_max_usage=$( cat $1 | jq '.memory.max_usage' )
	local mem_workingset=$( cat $1 | jq '.memory.working_set' )
	#mem_limit
	
        local mem_usage_body="mem_usage,PM=$PM,container=$3 value=$mem_usage $2"
        local mem_max_usage_body="mem_max_usage,PM=$PM,container=$3 value=$mem_max_usage $2"
	local mem_workingset_body="mem_workingset,PM=$PM,container=$3 value=$mem_workingset $2"

        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$mem_usage_body"
        curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$mem_max_usage_body"	
	curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$mem_workingset_body"
}

push_io_data(){
	local diskio_length=$( cat $1 | jq '.diskio' | jq length )
	
	for ((i=0;i<diskio_length;i++));do
		local io_device=$( cat $1 | jq ".diskio[$i].device" )
		local io_read=$( cat $1 | jq ".diskio[$i].stats.Read" )
		local io_write=$( cat $1 | jq ".diskio[$i].stats.Write" )
		local io_total=$( cat $1 | jq ".diskio[$i].stats.Total" )

		local io_read_body="io_read,PM=$PM,container=$3,device=$io_device value=$io_read $2"
                local io_write_body="io_write,PM=$PM,container=$3,device=$io_device value=$io_write $2"
		local io_total_body="io_write,PM=$PM,container=$3,device=$io_device value=$io_total $2"

                curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$io_read_body"
                curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$io_write_body"
		curl -i -XPOST 'http://141.223.82.62:8086/write?db=testdb' --data-binary "$io_total_body"
	done
}


push_fs_data(){
	local fs_length=$( cat $1 | jq '.filesystem' | jq length )

	for ((i=0;i<fs_length;i++)); do
		local device=$( cat $1 | jq ".filesystem[$i].device" )
        	local fs_capacity=$( cat $1 | jq ".filesystem[$i].capacity" )
        	local fs_usage=$( cat $1 | jq ".filesystem[$i].usage" )

		local fs_capacity_body="fs_capacity,PM=$PM,container=$3,device=$device value=$fs_capacity $2"
        	local fs_usage_body="fs_usage,PM=$PM,container=$3,device=$device value=$fs_usage $2"
		
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

		local rx_bytes_body="rx_bytes,PM=$PM,container=$3,interface=$iface value=$rx_bytes $2"
        	local rx_packets_body="rx_packets,PM=$PM,container=$3,interface=$iface value=$rx_packets $2"
        	local rx_errors_body="rx_errors,PM=$PM,container=$3,interface=$iface value=$rx_errors $2"
        	local rx_dropped_body="rx_dropped,PM=$PM,container=$3,interface=$iface value=$rx_dropped $2"
        	local tx_bytes_body="tx_bytes,PM=$PM,container=$3,interface=$iface value=$tx_bytes $2"
        	local tx_packets_body="tx_packets,PM=$PM,container=$3,interface=$iface value=$tx_packets $2"
        	local tx_errors_body="tx_errors,PM=$PM,container=$3,interface=$iface value=$tx_errors $2"
        	local tx_dropped_body="tx_dropped,PM=$PM,container=$3,interface=$iface value=$tx_dropped $2"

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
	push_io_data "$1" "$2" "$container"
        push_fs_data "$1" "$2" "$container"
	push_network_data "$1" "$2" "$container"
}

tmp_cp_stamp=0
tmp_dp_stamp=0
tmp_traffic_stamp=0

PM="dpnm_server"
CP=$( curl -X GET http://141.223.82.62:8080/api/v2.0/stats/cp?type=docker | awk -F: '{print $1}' | awk -F{ '{print $2}' )
DP=$( curl -X GET http://141.223.82.62:8080/api/v2.0/stats/dp?type=docker | awk -F: '{print $1}' | awk -F{ '{print $2}' )
TRAFFIC=$( curl -X GET http://141.223.82.62:8080/api/v2.0/stats/traffic?type=docker | awk -F: '{print $1}' | awk -F{ '{print $2}' )


for ((;;))
do
	curl -X GET http://141.223.82.62:8080/api/v2.0/stats/cp?type=docker | jq "(.$CP| reverse)[0] | {timestamp: .timestamp, cpu: .cpu, memory: .memory, diskio: .diskio.io_service_bytes, filesystem: .filesystem, network: .network.interfaces}" > cp.stats
	curl -X GET http://141.223.82.62:8080/api/v2.0/stats/dp?type=docker | jq "(.$DP| reverse)[0] | {timestamp: .timestamp, cpu: .cpu, memory: .memory, diskio: .diskio.io_service_bytes, filesystem: .filesystem, network: .network.interfaces}" > dp.stats
	curl -X GET http://141.223.82.62:8080/api/v2.0/stats/traffic?type=docker | jq "(.$TRAFFIC| reverse)[0] | {timestamp: .timestamp, cpu: .cpu, memory: .memory, diskio: .diskio.io_service_bytes, filesystem: .filesystem, network: .network.interfaces}" > traffic.stats

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

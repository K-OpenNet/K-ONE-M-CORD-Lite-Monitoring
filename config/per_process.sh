#!/bin/bash

for((;;))
do
	ps -o user,comm,pid,pcpu,pmem,vsize,size > process.txt
	cnt=0
	while read -r line;do
		if [ $cnt -eq 0 ];then
			cnt=1
		else
			user=$(echo $line | awk '{print $1}')
			name=$(echo $line | awk '{print $2}')
			pid=$(echo $line | awk '{print $3}')
			pcpu=$(echo $line | awk '{print $4}')
			pmem=$(echo $line | awk '{print $5}')
			vsize=$(echo $line | awk '{print $6}')
			size=$(echo $line | awk '{print $6}')

			per_process_body="process,PM='dpnm_server',name=$name,pid=$pid cpu=$pcpu,mem=$pmem,vsize=$vsize,size=$size"
			curl -i -XPOST 'http://141.223.82.62:8086/write?db=process' --data-binary "$per_process_body"
		fi
	done < process.txt
	cnt=0
	sleep 1s
done

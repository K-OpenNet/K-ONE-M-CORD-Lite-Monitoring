from time import time
from time import sleep
import requests
import subprocess
import datetime

instance1_ip="141.223.82.76"

while(True):
	for cnt in range (0,362):
		sleep(5)

		now = int(time())
		#print(now)

		#get cp's cpu usage
		cp_cpu_query = (
	    	('query', '100 - avg(collectd_cpu_percent{cpu=~"8|9|10|11",exported_instance="cp",instance="141.223.82.76:9103",job="collectd",type="idle"})'),
	    	('start', now-5),
	    	('end', now),
	    	('step', '5'),
		)

		dp_cpu_query = (
	    	('query', '100 - avg(collectd_cpu_percent{cpu=~"0|1|2|3|4|5|6|7",exported_instance="dp",instance="141.223.82.76:9103",job="collectd",type="idle"})'),
	    	('start', now-5),
	    	('end', now),
	    	('step', '5'),
		)

		cp_cpu_resp = requests.get('http://localhost:39090/api/v1/query_range', params=cp_cpu_query)
		cp_cpu_data = cp_cpu_resp.json()
		cp_cpu_value = cp_cpu_data["data"]["result"][0]["values"][1][1]
		#print(cp_cpu_value)


		dp_cpu_resp = requests.get('http://localhost:39090/api/v1/query_range', params=dp_cpu_query)
		dp_cpu_data = dp_cpu_resp.json()
		dp_cpu_value =  dp_cpu_data["data"]["result"][0]["values"][1][1]
		#print(dp_cpu_value)

		if __name__ == '__main__':
			print(datetime.datetime.now())
			runcommand_cp = "java -cp .:h2o-genmodel.jar main "+str(cnt)+" "+str(cp_cpu_value)
			cp_result = subprocess.check_output(runcommand_cp.split())
			cp_status = cp_result.decode('utf-8').split("\n")[0]
			print("CP - "+cp_status)
			if cp_status == "Abnormal":
				print(" - "+instance1_ip)

			runcommand_dp = "java -cp .:h2o-genmodel.jar main "+str(cnt)+" "+str(dp_cpu_value)
			dp_result = subprocess.check_output(runcommand_dp.split())
			dp_status = dp_result.decode('utf-8').split("\n")[0]
			print("DP - "+dp_status)
			if dp_status == "Abnormal":
				print(" - "+instance1_ip)
			print()

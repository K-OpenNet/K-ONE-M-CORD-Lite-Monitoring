
from scapy.all import *
from scapy.contrib import gtp
from scapy.contrib import gtp_v2

from collections import Counter
from time import time
#import time
from influxdb import InfluxDBClient

brs11 = "br-e16da23368de" #brs11
brs1u = "br-17ed1485facc"
brspgw = "br-0fa654a0c8d6"
brsgi = "br-7decab26cfd4"

packet_counts = Counter()
packet_bytes = {}

imsi_counts = Counter()
imsi_bytes = {}

teid_counts = Counter()
teid_bytes = {}

def parsing(pkt):		
	try:
		if (pkt[0][1].proto == 17 and pkt[0][2].dport == 2123): #GTPv2 packets
			parse_imsi(pkt,"GTPv2")
		elif (pkt[0][1].proto == 1 and pkt[0][4].dport == 2123): #ICMP in s11 gtpv2 ternel
			parse_imsi(pkt,"GTPv2_ICMP")
		elif (pkt[0][1].proto == 17 and pkt[0][2].dport == 2152): #GTP packets
			parse_teid(pkt,"GTP")
		elif (pkt[0][1].proto == 1 and pkt[0][4].dport == 2152): #ICMP in s1u gtp ternel
			parse_teid(pkt,"GTP_ICMP")
		else:
			parse_normal(pkt)
	except AttributeError as error:
                pkt[0].show()
	return

def parse_imsi(pkt,proto):
	try:#create session res
		#get imsi information
		imsi = pkt[0][4].IE_list[0].IMSI
		
		#get 5-tuple information
		src_ip = pkt[0][1].src
                dst_ip = pkt[0][1].dst
                protocol = proto
                sport = pkt[0][2].sport
                dport = pkt[0][2].dport
		info = tuple([src_ip,dst_ip,protocol,sport,dport,imsi])
		
		imsi_counts.update([info])
		pkt_bytes = pkt[0][1].len
		if info in imsi_bytes.keys():
			pkt_bytes += imsi_bytes[info]
			imsi_bytes.update({info : pkt_bytes})
		else:
			imsi_bytes.update({info : pkt_bytes})
	
	except AttributeError as error: #create session res, modify bearer req/res
                if (proto == "GTPv2_ICMP"):
			#get 5-tuple information
                        src_ip = pkt[0][1].src
                        dst_ip = pkt[0][1].dst
                        protocol = proto
                        sport = pkt[0][2].sport
                        dport = pkt[0][2].dport
                        imsi = 0 #temp
                        info = tuple([src_ip,dst_ip,protocol,sport,dport,imsi])

                        imsi_counts.update([info])
                        pkt_bytes = pkt[0][1].len
                        if info in imsi_bytes.keys():
                                pkt_bytes += imsi_bytes[info]
                                imsi_bytes.update({info : pkt_bytes})
                        else:
                                imsi_bytes.update({info : pkt_bytes})
		else:
			#get 5-tuple information
        	        src_ip = pkt[0][1].src
                	dst_ip = pkt[0][1].dst
	                protocol = proto
	                sport = pkt[0][2].sport
	                dport = pkt[0][2].dport
			imsi = 0 #temp
			info = tuple([src_ip,dst_ip,protocol,sport,dport,imsi])

			imsi_counts.update([info])
	                pkt_bytes = pkt[0][1].len
	                if info in imsi_bytes.keys():
	                        pkt_bytes += imsi_bytes[info]
	                        imsi_bytes.update({info : pkt_bytes})
	                else:
	                        imsi_bytes.update({info : pkt_bytes})

	return

def parse_teid(pkt,proto):
	try:
                #get imsi information
                teid = pkt[0][3].teid

                #get GRE ternel information
                t_src_ip = pkt[0][1].src
                t_dst_ip = pkt[0][1].dst
                t_protocol = proto
                
		#get real packet information
		src_ip = pkt[0][4].src
		dst_ip = pkt[0][4].dst
		protocol = pkt[0][4].proto
		sport = pkt[0][5].sport
                dport = pkt[0][5].dport

                info = tuple([teid,t_src_ip,t_dst_ip,t_protocol,src_ip,dst_ip,protocol,sport,dport])

                teid_counts.update([info])
                pkt_bytes = pkt[0][1].len
                if info in teid_bytes.keys():
                        pkt_bytes += teid_bytes[info]
                        teid_bytes.update({info : pkt_bytes})
                else:
                        teid_bytes.update({info : pkt_bytes})

        except AttributeError as error: #icmp
		#get imsi information
                teid = pkt[0][5].teid

                #get GRE ternel information
                t_src_ip = pkt[0][3].src
                t_dst_ip = pkt[0][3].dst
                t_protocol = proto

		#get real packet information
                src_ip = pkt[0][6].src
                dst_ip = pkt[0][6].dst
                protocol = pkt[0][6].proto
                sport = pkt[0][7].sport
                dport = pkt[0][7].dport

                info = tuple([teid,t_src_ip,t_dst_ip,t_protocol,src_ip,dst_ip,protocol,sport,dport])

                teid_counts.update([info])
                pkt_bytes = pkt[0][1].len
                if info in teid_bytes.keys():
                        pkt_bytes += teid_bytes[info]
                        teid_bytes.update({info : pkt_bytes})
                else:
                        teid_bytes.update({info : pkt_bytes})
        return


def parse_normal(pkt):
	try:
		#get 5 tuple information
		src_ip = pkt[0][1].src
		dst_ip = pkt[0][1].dst
		protocol = pkt[0][1].proto
		sport = pkt[0][2].sport
		dport = pkt[0][2].dport
		five_tuple = tuple([src_ip,dst_ip,protocol,sport,dport])

		packet_counts.update([five_tuple])
		pkt_bytes = pkt[0][1].len
		if five_tuple in packet_bytes.keys():
			pkt_bytes += packet_bytes[five_tuple]
			packet_bytes.update({five_tuple : pkt_bytes})
		else:
			packet_bytes.update({five_tuple : pkt_bytes})

        except AttributeError as error:
                pkt[0].show()

        return 


def push_teid_data(teid_data, measurement):
	for k,v in teid_data.items():
                json_body = [
                        {
                                "measurement": measurement,
                                "tags": {"PM": "dpnm",
                                        "interface": "br-s1u",
					"teid": k[0],
					"t_src_ip": k[1],
					"t_dst_ip": k[2],
					"t_protocol": k[3],
					"src_ip": k[4],
                                        "dst_ip": k[5],
                                        "protocol": k[6],
                                        "src_port": k[7],
                                        "dst_port": k[8]
                                },
                                "time": (int(time())*1000000000),
                                "fields": {
                                        measurement: v
                                }
                        }
                ]

                client = InfluxDBClient('141.223.82.62', 8086, 'root', 'root', 'packets')
                client.switch_database('packets')
                client.write_points(json_body)
	return


def push_imsi_data(imsi_data, measurement):
	for k,v in imsi_data.items():
		#get interface
                if("192.168.103." in k[0] or "192.168.103." in k[1]):
                        iface = "br-s11"
                elif("192.168.104." in k[0] or "192.168.104." in k[1]):
                        iface = "br-spgw"
                elif("192.168.105." in k[0] or "192.168.105." in k[1]):
                        iface = "br-s1u"
                elif("13.1.1." in k[0] or "16.255.255." in k[1] or "13.1.1." in k[1] or "16.255.255." in k[0]):
                        iface = "br-sgi"
                else:
                        iface = "others"

		json_body = [
			{
				"measurement": measurement,
				"tags": {"PM": "dpnm",
					"interface": iface,
					"src_ip": k[0],
                                        "dst_ip": k[1],
                                        "protocol": k[2],
                                        "src_port": k[3],
                                        "dst_port": k[4],
					"IMSI": k[5]
				},
				"time": (int(time())*1000000000),
				"fields": {
					measurement: v
				}
			}
		]
		
		client = InfluxDBClient('141.223.82.62', 8086, 'root', 'root', 'packets')
                client.switch_database('packets')
                client.write_points(json_body)

def push_data(pkt_data,measurement):
	for k,v in pkt_data.items():
		#get protocol type
		if (k[3] == 2123 or k[4] == 2152):
			protocol = "gtp"
		else:
			if (k[2] == 17):
				protocol = "udp"
			elif (k[2] == 1):
				protocol = "icmp"
			elif (k[2] == 6):
				protocol = "tcp"
			else:
				protocol = "other"
		#get interface
		if("192.168.103." in k[0] or "192.168.103." in k[1]):
			iface = "brs11"
		elif("192.168.104." in k[0] or "192.168.104." in k[1]):
			iface = "brspgw"
		elif("192.168.105." in k[0] or "192.168.105." in k[1]):
                        iface = "brs1u"
		elif("13.1.1." in k[0] or "16.255.255." in k[1] or "13.1.1." in k[1] or "16.255.255." in k[0]):
                        iface = "brsgi"
		else:
			iface = "other"
		#create json body
		json_body = [
			{
				"measurement": measurement,
				"tags": {"PM": "dpnm",
					"interface": iface,
					"src_ip": k[0],
					"dst_ip": k[1],
					"protocol": protocol,
					"src_port": k[3],
					"dst_port": k[4]
				},
				"time": (int(time())*1000000000),
				"fields": {
					measurement: v
				}

			}
		]

		client = InfluxDBClient('141.223.82.62', 8086, 'root', 'root', 'packets')
		client.switch_database('packets')
		client.write_points(json_body)
	return


while True:
	#sniff packetsv
	pkts=sniff(iface=[brs11,brs1u,brsgi,brspgw], filter="ip", prn=parsing, timeout=10)
	#push_data to influx db
	#print(str(int(time())))
	push_data(packet_counts,"packet_counts")
	push_data(packet_bytes,"packet_bytes")
	
	push_imsi_data(imsi_counts,"imsi_counts")
	push_imsi_data(imsi_bytes,"imsi_bytes")
	
	push_teid_data(teid_counts,"teid_counts")
	push_teid_data(teid_bytes,"teid_bytes")


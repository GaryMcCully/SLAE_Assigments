#!/usr/bin/python

import sys


IPAddress=sys.argv[1]
Port=int(sys.argv[2])
PortLength = len("{:02x}".format(Port))

if len(sys.argv) != 3 or Port < 1 or Port > 65535:
	print ('Usage ./IP_Port_Converter.py IP PORT')

else:
	a=IPAddress.split('.')
	print "Here is the IP Address Value to enter: "+ "0x{:02x}".format(int(a[3]))+"{:02x}".format(int(a[2]))+"{:02x}".format(int(a[1]))+"{:02x}".format(int(a[0]))	
	if PortLength %2==1:
		Port="0"+str("{:02x}".format(int(Port)))

	else:
		Port=str("{:02x}".format(int(Port)))

	if len(Port) == 4:
		PortPt1,PortPt2 = Port[:len(Port)/2], Port[len(Port)/2:]
		print "Here is the Port Value to enter: 0x"+ PortPt2+PortPt1
	else:
		print "Here is the Port Value to enter: 0x"+ Port



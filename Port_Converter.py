#!/usr/bin/python

import sys

Port=int(sys.argv[1])
PortLength = len("{:02x}".format(Port))

if len(sys.argv) > 2 or Port < 1 or Port > 65535:
	print ('Usage ./Port_Converter.py PORT')

else:	
	if PortLength %2==1:
		Port="0"+str("{:02x}".format(int(Port)))

	else:
		Port=str("{:02x}".format(int(Port)))

	if len(Port) == 4:
		PortPt1,PortPt2 = Port[:len(Port)/2], Port[len(Port)/2:]
		print "Here is the Port Value to enter: 0x"+ PortPt2+PortPt1
	else:
		print "Here is the Port Value to enter: 0x"+ Port



#!/bin/bash 

if ! iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE > /dev/null 2>&1 ; then 
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE	
fi


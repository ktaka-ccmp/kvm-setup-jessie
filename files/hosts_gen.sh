#!/bin/bash

hosts=/etc/hosts
#hosts=/tmp/hosts

touch ./hosts.tmp

for i in {1..250} ; do 
	if ! egrep "172.16.1.$i"  $hosts > /dev/null ; then
		echo -e "172.16.1.$i\tv$(printf %03d $i)" >> ./hosts.tmp
	fi
done  

cat $hosts > $hosts.$(date +"%Y%m%d%H%M" -r $hosts)
cat ./hosts.tmp >> $hosts

rm ./hosts.tmp

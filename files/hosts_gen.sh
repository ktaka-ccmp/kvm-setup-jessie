#!/bin/bash

hosts=/etc/hosts
#hosts=/tmp/hosts

touch ./hosts.tmp

for i in {1..250} ; do 
	if ! egrep "10\.0\.$i\.0"  $hosts > /dev/null ; then
		echo -e "10.0.$i.0\tv$(printf %03d $i)" >> ./hosts.tmp
	fi
done  

cat $hosts > $hosts.$(date +"%Y%m%d%H%M" -r $hosts)
cat ./hosts.tmp >> $hosts

rm ./hosts.tmp

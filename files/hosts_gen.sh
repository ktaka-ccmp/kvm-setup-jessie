#!/bin/bash

hosts=/etc/hosts
#hosts=/tmp/hosts

touch ./hosts.tmp

for j in 0 ; do 
for i in {1..250} ; do 
	if ! egrep "10.0.$j.$i"  $hosts > /dev/null ; then
		echo -e "10.0.$j.$i\tv$(printf %03d $i)" >> ./hosts.tmp
	fi
done  
done

cat $hosts > $hosts.$(date +"%Y%m%d%H%M" -r $hosts)
cat ./hosts.tmp >> $hosts

rm ./hosts.tmp

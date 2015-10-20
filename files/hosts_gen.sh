#!/bin/bash

for i in {1..250} ; do echo -e "192.168.1.$i\tv$(printf %03d $i)" ; done  


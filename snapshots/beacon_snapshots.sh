#!/bin/bash
#
# Copyright © 2022 ExinPool <robin@exin.one>
#
# Distributed under terms of the MIT license.
#
# Desc: Beacon Nodes Snaptshots.
# User: Robin@ExinPool
# Date: 2022-05-23
# Time: 17:04:59

apikey=$1
nodes=(`cat nodes.log`)

curdate=$(date '+%Y-%m-%d')

cd /data/monitor/exinpool/Ethereum && mkdir -p data/$curdate
dir="/data/monitor/exinpool/Ethereum/data/$curdate"

for node in "${nodes[@]}"
do
    file="$dir/snaptshots-$curdate.log"
    balanceBig=`curl --silent -X 'GET' 'https://beaconcha.in/api/v1/validator/$node?apikey=$apikey' -H 'accept: application/json' | jq | grep -w balance | awk -F':' '{print $2}' | sed "s/ //g" | sed "s/,//g"`
    balance=`echo "scale=9; $balanceBig/1000000000" | bc`
    echo "$node $balance" >> $file
done
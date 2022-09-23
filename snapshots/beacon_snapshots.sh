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

nodes=(`cat nodes.log`)

curdate=$(date '+%Y-%m-%d')

cd /data/monitor/exinpool/Ethereum && mkdir -p data/$curdate
dir="/data/monitor/exinpool/Ethereum/data/$curdate"

for node in "${nodes[@]}"
do
    file="$dir/snaptshots-$curdate.log"
    balance=`curl --silent https://beaconscan.com/main/validator/$node | grep "est APR of" | awk '{print $1}'`
    apr=`curl --silent https://beaconscan.com/main/validator/$node | grep "est APR of" | awk -F'(' '{print $2}' | awk -F'%' '{print $1}' | awk '{print $4}'`
    echo "$node $balance $apr" >> $file
done
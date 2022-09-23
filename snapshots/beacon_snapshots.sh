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
    balance=`curl -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" --silent https://beaconscan.com/main/validator/0x$node | grep "est APR of" | awk '{print $1}'`
    apr=`curl -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.182 Safari/537.36" --silent https://beaconscan.com/main/validator/0x$node | grep "est APR of" | awk -F'(' '{print $2}' | awk -F'%' '{print $1}' | awk '{print $4}'`
    echo "$node $balance $apr" >> $file
done
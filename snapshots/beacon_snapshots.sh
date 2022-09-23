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

# load the config library functions
source config.shlib

# load configuration
service="$(config_get SERVICE)"
api_key="$(config_get API_KEY)"
log_file="$(config_get LOG_FILE)"
lark_webhook_url="$(config_get LARK_WEBHOOK_URL)"

nodes=(`cat nodes.log`)
curdate=$(date '+%Y-%m-%d')

cd /data/monitor/exinpool/Ethereum && mkdir -p data/$curdate
dir="/data/monitor/exinpool/Ethereum/data/$curdate"

for node in "${nodes[@]}"
do
    file="$dir/snaptshots-$curdate.log"
    balanceBig=`curl --silent -X 'GET' 'https://beaconcha.in/api/v1/validator/$node?apikey=$api_key' -H 'accept: application/json' | jq '.data.balance'`
    balance=`echo "scale=9; $balanceBig/1000000000" | bc`
    echo "$node $balance" >> $file

    log="时间: `date '+%Y-%m-%d %H:%M:%S'` UTC \n主机名: `hostname` \n节点: ${service}\n状态: 快照已完成。"
    echo -e $log >> $log_file
    curl -X POST -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"'"$log"'"}}' ${lark_webhook_url}
done
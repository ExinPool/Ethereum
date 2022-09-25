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
node_num="$(config_get NODE_NUM)"
log_file="$(config_get LOG_FILE)"
lark_webhook_url="$(config_get LARK_WEBHOOK_URL)"

nodes=(`cat nodes.log`)
curdate=$(date '+%Y-%m-%d')

cd /data/monitor/exinpool/Ethereum && mkdir -p data/$curdate
dir="/data/monitor/exinpool/Ethereum/data/$curdate"
file="$dir/snaptshots-$curdate.log"

for node in "${nodes[@]}"
do
    balanceBig=`curl --silent -X 'GET' "https://beaconcha.in/api/v1/validator/$node?apikey=$api_key" -H 'accept: application/json' | jq '.data.balance'`
    balance=`echo "scale=9; $balanceBig/1000000000" | bc`
    if (( $(echo "$balance > $32.0" | bc -l) )); then
        echo "$node $balance" >> $file
    else
        balanceBig=`curl --silent -X 'GET' "https://beaconcha.in/api/v1/validator/$node?apikey=$api_key" -H 'accept: application/json' | jq '.data.balance'`
        balance=`echo "scale=9; $balanceBig/1000000000" | bc`
        echo "$node $balance" >> $file
    fi
done

curnum=`cat $file | awk '$2 > 32.0 {print $2;}' | wc -l`

if [ "$curnum" -eq "${node_num}" ]; then
    log="时间: `date '+%Y-%m-%d %H:%M:%S'` UTC \n主机名: `hostname` \n节点: ${service}\n状态: 快照已完成。"
    echo -e $log >> /data/monitor/exinpool/Ethereum/snapshots/$log_file
    curl -X POST -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"'"$log"'"}}' ${lark_webhook_url}
else
    log="时间: `date '+%Y-%m-%d %H:%M:%S'` UTC \n主机名: `hostname` \n节点: ${service}\n状态: 快照失败，请立即检查。"
    echo -e $log >> /data/monitor/exinpool/Ethereum/snapshots/$log_file
    curl -X POST -H "Content-Type: application/json" -d '{"msg_type":"text","content":{"text":"'"$log"'"}}' ${lark_webhook_url}
fi
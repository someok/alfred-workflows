#!/bin/bash
# set -ue -o pipefail

LOCAL_IP=(`ifconfig | grep 'inet ' | grep -v ' 127.' | cut -d ' ' -f 2`)

PUBLIC_JSON=`curl -s "https://ip.cn/api/index?ip=&type=0"`
PUBLIC_ADDRESS=`echo -n ${PUBLIC_JSON} | awk -F ',' '{print $3}' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`
PUBLIC_IP=`echo -n ${PUBLIC_JSON} | awk -F ',' '{print $4}' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`

# echo ${PUBLIC_IP}
# echo ${PUBLIC_ADDRESS}

cat << _JSON_
{"items": [
    {
        "uid": "localip0",
        "title": "${LOCAL_IP}",
        "subtitle": "本地 IP",
        "arg": "${LOCAL_IP}",
        "autocomplete": "${LOCAL_IP}",
        "valid": true
    },
    {
        "uid": "publicip",
        "title": "${PUBLIC_IP}",
        "subtitle": "公网 IP",
        "arg": "${PUBLIC_IP}",
        "autocomplete": "${PUBLIC_IP}",
        "valid": true
    },
    {
        "uid": "publicaddress",
        "title": "${PUBLIC_ADDRESS}",
        "subtitle": "公网地址",
        "arg": "${PUBLIC_ADDRESS}",
        "autocomplete": "${PUBLIC_ADDRESS}",
        "valid": true
    }
]}
_JSON_

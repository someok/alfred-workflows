#!/bin/bash
# set -ue -o pipefail

LOCAL_IP=($(ifconfig | grep 'inet ' | grep -v ' 127.' | cut -d ' ' -f 2))

LOCAL_JSON=""
index=0
for ip in "${LOCAL_IP[@]}"; do
  LOCAL_JSON+=$(cat << EOF
    ,{
        "uid": "localip${index}",
        "title": "${ip}",
        "subtitle": "本地 IP ${index}",
        "arg": "${ip}",
        "autocomplete": "${ip}",
        "valid": true
    }
EOF
  )

  ((index++))
done
#echo "${LOCAL_JSON}"

# ip.cn 经常 down 掉，所以换一个实现
# PUBLIC_JSON=`curl -s "https://ip.cn/api/index?ip=&type=0"`
# PUBLIC_ADDRESS=`echo -n ${PUBLIC_JSON} | awk -F ',' '{print $3}' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`
# PUBLIC_IP=`echo -n ${PUBLIC_JSON} | awk -F ',' '{print $4}' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`

IP_DATA=$(curl -sL ip.tool.lu)

arr=()
while read -r line; do
   arr+=("$line")
done <<< "$IP_DATA"

PUBLIC_IP=$(echo "${arr[0]##*: }" | tr -d "\r")
PUBLIC_ADDRESS=$(echo "${arr[1]##*: }" | tr -d "\r")

# echo ${PUBLIC_IP}
# echo ${PUBLIC_ADDRESS}

cat << _JSON_
{"items": [
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
    ${LOCAL_JSON}
]}
_JSON_

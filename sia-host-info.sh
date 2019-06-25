#!/usr/bin/env bash
# Author: Stefan Crawford
# Description: Take in host information eg. "siac host -v" and create report

# Requires: jq
### To Install ###
# sudo dnf -y install jq

### function to print multiple blank lines
function lines { yes '' | sed ${1}q ; }

# define RAM
readonly MEM=/dev/shm
readonly HOST=localhost:9980
readonly CURL="curl -s --compressed --limit-rate 1M --connect-timeout 5  --compressed --limit-rate 1M --connect-timeout 5"
readonly SIA_HOST_DATE=$( date --rfc-3339=ns )

# cache date and atomic time in RFC-3339 format & print cached list
printf "\nCaching date... " && redis-cli -n 0 LPUSH SIA_HOST_DATE "$SIA_HOST_DATE" && redis-cli LRANGE SIA_HOST_DATE 0 -1

# load initial host info into MEM
$CURL -i -A "Sia-Agent" -u "":foobar $HOST/host | grep { > $MEM/SIA_HOST_INFO

####### External Settings - Start #######
printf "\nCaching external maxdownloadbatchsize... " && redis-cli -n 0 LPUSH externalmaxdownloadbatchsize $( cat $MEM/SIA_HOST_INFO | jq .externalsettings | jq -r .maxdownloadbatchsize ) && redis-cli LRANGE externalmaxdownloadbatchsize 0 -1
printf "\nCaching external maxduration... " && redis-cli -n 0 LPUSH externalmaxduration $( cat $MEM/SIA_HOST_INFO | jq .externalsettings | jq -r .maxduration ) && redis-cli LRANGE externalmaxduration 0 -1
printf "\nCaching external maxrevisebatchsize... " && redis-cli -n 0 LPUSH externalmaxrevisebatchsize $( cat $MEM/SIA_HOST_INFO | jq .externalsettings | jq -r .maxrevisebatchsize ) && redis-cli LRANGE externalmaxrevisebatchsize 0 -1
array=( remainingstorage sectorsize totalstorage unlockhash )
for i in "${array[@]}"
do
   : 
   printf "\nCaching $i... Total: " && redis-cli -n 0 LPUSH $i $( cat $MEM/SIA_HOST_INFO | jq .externalsettings | jq -r .$i ) && redis-cli LRANGE $i 0 -1
done
printf "\nCaching external netaddress... " && redis-cli -n 0 LPUSH externalnetaddress $( cat $MEM/SIA_HOST_INFO | jq .externalsettings | jq -r .netaddress ) && redis-cli LRANGE externalnetaddress 0 -1
printf "\nCaching external acceptingcontracts... " && redis-cli -n 0 LPUSH externalacceptingcontracts $( cat $MEM/SIA_HOST_INFO | jq .externalsettings | jq -r .acceptingcontracts ) && redis-cli LRANGE externalacceptingcontracts 0 -1
####### External Settings - End #######

####### Financial Metrics - Start #######
array=( contractcount contractcompensation potentialcontractcompensation  lockedstoragecollateral lostrevenue loststoragecollateral potentialstoragerevenue riskedstoragecollateral storagerevenue transactionfeeexpenses downloadbandwidthrevenue potentialdownloadbandwidthrevenue potentialuploadbandwidthrevenue uploadbandwidthrevenue )
for i in "${array[@]}"
do
   : 
   printf "\nCaching $i... Total: " && redis-cli -n 0 LPUSH $i $( cat $MEM/SIA_HOST_INFO | jq .financialmetrics | jq -r .$i ) && redis-cli LRANGE $i 0 -1
done
####### Financial Metrics - End #######

####### Internal Settings - Start #######
printf "Internal Settings:"
lines 1
array=( acceptingcontracts maxdownloadbatchsize maxduration maxrevisebatchsize netaddress windowsize collateral collateralbudget maxcollateral minbaserpcprice mincontractprice mindownloadbandwidthprice minsectoraccessprice minstorageprice minuploadbandwidthprice )
for i in "${array[@]}"
do
   : 
   printf "\nCaching $i... Total: " && redis-cli -n 0 LPUSH $i $( cat $MEM/SIA_HOST_INFO | jq .internalsettings | jq -r .$i ) && redis-cli LRANGE $i 0 -1
done
####### Internal Settings - End #######

####### RPC Stats aka netmetrics - Start #######
array=( downloadcalls errorcalls formcontractcalls renewcalls revisecalls settingscalls unrecognizedcalls )
for i in "${array[@]}"
do
   : 
   printf "\nCaching $i... Total: " && redis-cli -n 0 LPUSH $i $( cat $MEM/SIA_HOST_INFO | jq .networkmetrics | jq .$i ) && redis-cli LRANGE $i 0 -1
done
array=( connectabilitystatus workingstatus )
for i in "${array[@]}"
do
   : 
   printf "\nCaching $i... Total: " && redis-cli -n 0 LPUSH $i $( cat $MEM/SIA_HOST_INFO | jq -r .$i ) && redis-cli LRANGE $i 0 -1
done
####### RPC Stats - End #######

####### Storage Folders #######
# take Storage Folders info into an array
# STORAGE_FOLDERS=$( cat $MEM/SIAC_HOST_V | grep -A 3 "Storage Folders:" | tail -n 1 )
# 
# printf "%s " ${ARRAY[*]}
####### Storage Folders - End #######

#!/bin/bash
set +e

if [ $# -eq 1 ]; then
    firstDate="${1}01"
else
    firstDate=`date +"%Y%m01"`
fi

lastday=`date -v+1m -v-1d -j -f "%Y%m%d" ${firstDate} +'%d'`

rebootTimes=()
shutdownTimes=()

shutdownList=`last | grep "^shutdown" | cut -d " " -f 28-33`
while read line;
do
    curdate=`env LANG=eu_US.UTF-8 date -j -f "%a %b %d %H:%M" "${line}" "+%Y%m%d"`
    curtime=`env LANG=eu_US.UTF-8 date -j -f "%a %b %d %H:%M" "${line}" "+%H:%M"`
    if [ -z "${shutdownTimes[${curdate}]}" ]; then
        shutdownTimes[${curdate}]="$curtime"
    fi
done << END
$shutdownList
END

rebootList=`last | grep "^reboot" | cut -d " " -f 30-35`
while read line;
do
    curdate=`env LANG=eu_US.UTF-8 date -j -f "%a %b %d %H:%M" "${line}" "+%Y%m%d"`
    curtime=`env LANG=eu_US.UTF-8 date -j -f "%a %b %d %H:%M" "${line}" "+%H:%M"`
    rebootTimes[${curdate}]=${curtime}
done << END
$rebootList
END

for ((i=0; i < ${lastday}; i++)); do
    target=`date -v+${i}d -j -f "%Y%m%d" "${firstDate}" +"%Y%m%d"`
    display_date=`date -v+${i}d -j -f "%Y%m%d" "${firstDate}" +"%Y/%m/%d"`
    echo "${display_date} : ${rebootTimes[${target}]} - ${shutdownTimes[${target}]}"
done


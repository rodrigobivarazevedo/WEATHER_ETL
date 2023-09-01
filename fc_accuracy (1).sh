#!/bin/bash

yesterday_fc=$(tail -2 rx_poc.log | head -1 | awk '{print $6}')
today_temp=$(tail -1 rx_poc.log | awk '{print $5}' )
accuracy=$(($yesterday_fc-$today_temp))


if [ -1 -le $accuracy ] && [ $accuracy -le 1 ]
then
   accuracy_range=excellent
elif [ -2 -le $accuracy ] && [ $accuracy -le 2 ]
then
    accuracy_range=good
elif [ -3 -le $accuracy ] && [ $accuracy -le 3 ]
then
    accuracy_range=fair
else
    accuracy_range=poor
fi

echo "Forecast accuracy is $accuracy"


row=$(tail -1 rx_poc.log)
year=$( echo $row | awk '{print $1}')
month=$( echo $row | awk '{print $2}')
day=$( echo $row | awk '{print $3}')
echo -e "$year\t$month\t$day\t\t$today_temp\t\t$yesterday_fc\t\t$accuracy\t\t$accuracy_range" >> historical_fc_accuracy.tsv
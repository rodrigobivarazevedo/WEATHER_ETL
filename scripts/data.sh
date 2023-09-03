#! /bin/bash

# create a datestamped filename for the raw wttr data:
today=$(date +%Y%m%d)
weather_report=/workspaces/WEATHER_ETL/raw_data_$today

# download today's weather report from wttr.in:
city=LISBON
curl "wttr.in/$city?T" --output "$weather_report"

# use command substitution to store the current day, month, and year in corresponding shell variables:
hour=$(TZ='Germany/Munich' date -u +%H)
day=$(TZ='Germany/Munich' date -u +%d)
month=$(TZ='Germany/Munich' date +%m)
year=$(TZ='Germany/Munich' date +%Y)

# extract all lines containing temperatures from the weather report and write to file
grep °C $weather_report > /workspaces/WEATHER_ETL/temperatures.txt

# extract the current temperature

obs_temp=$(cat -A temperatures.txt | head -1 | cut -d "+" -f2 | cut -d "(" -f1 | grep -oE '[0-9]+\b')

echo "observed = $obs_temp"

# extract the forecast for noon tomorrow
fc_temp=$(cat -A temperatures.txt | head -3 | tail -1 | cut -d "+" -f2 | cut -d "(" -f1 | cut -d "^" -f1 )
echo "fc temp = $fc_temp"

# Create a tab-delimited record and append it to rx_poc.log:
record="$year\t$month\t$day\t$hour\t\t$obs_temp\t\t$fc_temp"
echo -e "$record" >> /workspaces/WEATHER_ETL/logs/rx_poc.log


#!/bin/bash

# Create a date-stamped filename for the raw wttr data:
today=$(date +%Y%m%d)
weather_report="raw_data_$today"
# Calculate the date of the next day
next_day=$(date -d "$today + 1 day" +%Y%m%d)

# Download today's weather report from wttr.in for Casablanca with current weather and the next day's forecast:
city="Lisbon"
curl "wttr.in/$city?T" --output "$weather_report"

# Use command substitution to store the current day, month, and year in corresponding shell variables:
hour=$(TZ='Africa/Casablanca' date -u +%H)
day=$(TZ='Africa/Casablanca' date -u +%d)
month=$(TZ='Africa/Casablanca' date +%m)
year=$(TZ='Africa/Casablanca' date +%Y)

# Extract all lines containing temperatures from the weather report and write to a file:
grep "°C"  "$weather_report" > temperatures.txt

# Extract current temperature (first line) and forecasted temperature for noon next day (second line)
obs_temp=$(sed -n '1p' temperatures.txt | awk '{print $3}')
fc_temp=$(sed -n '3p' temperatures.txt | awk '{print $8}')

echo "observed = $obs_temp"
echo "fc temp = $fc_temp"


# Create a tab-delimited record and append it to rx_poc.log:
record="$year\t$month\t$day\t$hour\t\t$obs_temp\t\t$fc_temp"
echo -e "$record" >> rx_poc.log

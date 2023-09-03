#!/bin/bash

echo $(tail -7  /workspaces/WEATHER_ETL/statistics/historical_fc_accuracy.tsv  | awk '{print $6}') > scratch.txt

week_fc=($(echo $(cat scratch.txt)))


# Define the abs function to calculate the absolute value
abs() {
  if (( $1 < 0 )); then
    echo $((-1 * $1))
  else
    echo $1
  fi
}

# Initialize variables to store minimum and maximum values
min_error=$(abs ${week_fc[0]})
max_error=$(abs ${week_fc[0]})

# Loop through the array to find the minimum and maximum absolute errors
for num in "${week_fc[@]}"; do
    # Calculate the absolute value using the abs function
    num_abs=$(abs $num)

    # Compare current absolute number with the minimum
    if ((num_abs < min_error)); then
        min_error=$num_abs
    fi

    # Compare current absolute number with the maximum
    if ((num_abs > max_error)); then
        max_error=$num_abs
    fi
done

# Initialize variables to store counts for different accuracy ranges
count_excellent=0
count_good=0
count_fair=0
count_poor=0

nlines=$(wc -l < /workspaces/WEATHER_ETL/statistics/historical_fc_accuracy.tsv)
# Read the accuracy ranges from the last 7 lines in the file and update counts accordingly
for ((i=nlines; i>nlines-7; i--)); do
    accuracy_range=$(sed -n "${i}p" /workspaces/WEATHER_ETL/statistics/historical_fc_accuracy.tsv | awk '{print $7}')
    case "$accuracy_range" in
        "excellent") count_excellent=$((count_excellent + 1));;
        "good") count_good=$((count_good + 1));;
        "fair") count_fair=$((count_fair + 1));;
        "poor") count_poor=$((count_poor + 1));;
    esac
done

# Initialize the variable to store the highest count
highest_count=""
# Initialize the maximum count to a very low value
max_count=-99999

# Compare each count with the current maximum and update if necessary
if [ $count_excellent -gt $max_count ]; then
    max_count=$count_excellent
    highest_count="excellent"
fi

if [ $count_good -gt $max_count ]; then
    max_count=$count_good
    highest_count="good"
fi

if [ $count_fair -gt $max_count ]; then
    max_count=$count_fair
    highest_count="fair"
fi

if [ $count_poor -gt $max_count ]; then
    max_count=$count_poor
    highest_count="poor"
fi

# Print the results with appropriate formatting
echo "min_error: $min_error"
echo "max_error: $max_error"
echo "count_poor: $count_poor"
echo "count_fair: $count_fair"
echo "count_good: $count_good"
echo "count_excellent: $count_excellent"
echo "The variable with the highest count is: $highest_count"

current_date=$(date +"%-d %B %Y")
# Append the results to the weekly report file
echo -e "$current_date\t\t\t$min_error\t\t\t$max_error\t\t\t$count_poor\t\t\t$count_fair\t\t\t$count_good\t\t\t$count_excellent\t\t\t$highest_count" >> /workspaces/WEATHER_ETL/statistics/weekly_report.tsv

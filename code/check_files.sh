#!/bin/bash
#count the number of  participants there are with body measures and accelerometer data
# grep -h "ID=" data/original/accel/*.txt | wc -l
# What format are the data files in
# sed -n '2p' data/original/accel/accel-41474.txt | sed 's/\t/\n/g' | cat -n
#  and what information they contain

# check if all accelerometer files have the same header line
output="data/derived/accel_headers.txt"
> "$output"

for file in data/original/accel/*.txt; do
  echo "$(basename "$file"): $(sed -n '2p' "$file")" >> "$output"
done
unique_headers=$( cut -d: -f2 data/derived/accel_headers.txt |uniq -c| wc -l )

if [ "$unique_headers" -eq 1 ]; then
  echo -e "All accelerometer files have the same header line. \n Proceeding with processing.\n"
else
  echo "\n Accelerometer files have different header lines. \nß Please check the following headers:"
  cut -d: -f2 data/derived/accel_headers.txt |uniq -c
fi

# there are the right number of columns on each row of each file 
# awk -F '\t' 'NR > 1 {print NF; exit}' data/original/accel/accel-41474.txt
# awk -F'\t' -v expected="$header_columns" \
#   'NF != expected {print NR ": " $0; exit}' data/original/accel/accel-41474.txt

output2="data/derived/accel_columns.txt"
echo "Files with incorrect column counts:" > "$output2"

#number of columns in header line
header_columns=$(awk -F'\t' 'NR==1 {print NF; exit}' data/derived/accel_headers.txt)
echo -e "Header line has:\n$header_columns columns."  

for file in data/original/accel/*.txt; do
  num_columns=$(awk -F'\t' '{print NF; exit}' "$file")
  if [ "$num_columns" -ne $header_columns ]; then
  echo "$(basename "$file"): 
  $(awk -F'\t' -v expected="$header_columns" \
  'NF != expected {print NR ": " $0; exit}' "$file")" >> "$output2"
  fi
  awk -F'\t' -v expected="$header_columns" \
  'NF == expected {print $0}' "$file" \
  > "data/derived/accel/$(basename "$file")"
done

echo -e "\n\nRemoving lines with NA\tNA\tNA\n"

# remove those lines
sed -i '' '/NA\tNA\tNA/d' data/derived/accel/accel-*.txt

echo "new data files are stored in the data/derived directory."

#!/bin/bash

allFiles=$(ls -lRtTr .lolcommits/*/*.jpg ) # T: always print year, t: sort by date, r: reverse
dateList=$(echo "$allFiles" | awk '{printf("%s\\s*%d.*%d\n", $6, $7, $9)}' | uniq)

mkdir -p results results/montages results/annotated results/intermediates
for date in $dateList;
do
    filesOnThisDate=$(echo "$allFiles" | grep -p "$date" | awk '{print $10}')
    dateWithoutRegex=$(echo $date | tr -d '.\\s *') # Luckly, no month has lowercase s
    dateWithSpaces=$(echo $date | tr -d '.\\s ' | tr '*' ' ')

    echo $dateWithSpaces

    filename=${dateWithoutRegex}.png
    montage -geometry 640x480 -background Black $filesOnThisDate results/montages/$filename

    convert results/montages/$filename \
        -resize 800x450 -size 800x450\! \
        -gravity north  -extent 800x450 \
        results/intermediates/$filename
    convert results/intermediates/$filename \
        -gravity south -pointsize 30 \
        -stroke '#000C' -strokewidth 10 -annotate 0 "$dateWithSpaces" \
        -stroke  none   -fill white     -annotate 0 "$dateWithSpaces" \
        results/annotated/$filename
done

convert `find annotated -type f -name "*.png" -print0 | xargs -0 ls -tlr | awk '{print $9}'` movie.mp4

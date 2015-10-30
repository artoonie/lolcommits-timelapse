#!/bin/bash

allFiles=$(ls -lRtTr .lolcommits/*/*.jpg ) # T: always print year, t: sort by date, r: reverse
# dateList=$(echo "$allFiles" | awk '{printf("%d %s %d : %s\n", $9, $6, $7, $10)}' | uniq)
dateList=$(echo "$allFiles" | awk '{printf("%s.*%d.*%d\n", $6, $7, $9)}' | uniq)

mkdir -p results results/montages results/annotated results/intermediates
for date in $dateList;
do
    filesOnThisDate=$(echo "$allFiles" | grep $date | awk '{print $10}')
    # echo "On date $date, files are $filesOnThisDate"
    dateWithoutDot=$(echo $date | tr -d '.' | tr -d '*')
    dateWithSpaces=$(echo $date | tr -d '.' | tr '*' ' ')
    filename=${dateWithoutDot}.png
    echo $dateWithSpaces
    montage -geometry 640x480 -background Black $filesOnThisDate results/montages/$filename
    # convert montages/$filename \
    #         -gravity Center -background Black -fill Gray \
    #         -pointsize 70 \
    #         -resize 800x450\! -size 800x450\! \
    #         label:"$dateWithSpaces" -append  annotated/$filename
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

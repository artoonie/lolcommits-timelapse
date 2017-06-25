#!/bin/bash
# See the README for usage

# Prepare the input and output
allFiles=$(ls -lRtTr ~/.lolcommits/*/*.jpg ) # T: always print year, t: sort by date, r: reverse
dateList=$(echo "$allFiles" | awk '{printf("%s\\s*%d.*%d\n", $6, $7, $9)}' | uniq)
mkdir -p results results/montages results/annotated results/intermediates

# Create an argument list to be passed into xargs for makeImageForDay
args=""
filenameList=""
for date in $dateList;
do
    filesOnThisDate=$(echo "$allFiles" | grep -p "$date" | awk '{print $10}')
    dateWithoutRegex=$(echo $date | tr -d '.\\s *') # Luckly, no month has lowercase s
    dateWithSpaces=$(echo $date | tr -d '.\\s ' | tr '*' ' ')

    echo $dateWithSpaces

    filename=${dateWithoutRegex}.png
    args="$args '$filesOnThisDate' '$filename' '$dateWithSpaces'"
    filenameList="$filenameList $filename"
done

# Run makeImageForDay via xargs
echo $args | xargs -P9 -n3 ./makeImageForDay.sh

#####
# For some reason imagemagick is producing corrupt files when doing this the old way:
# convert `find results/annotated -type f -name "*.png" -print0 | xargs -0 ls -tlr | awk '{print $9}'` movie.mp4
# So let's move files around for consumption by ffmpeg
# We can also mv instead of cp for efficiency, but I like keeping the originals in tact
#####

# Sort the annotated images by date and copy to a ffmpeg-friendly filename
j=0;
mkdir -p results/copies
rm results/copies/*
for i in $filenameList;
do
    cp results/annotated/$i results/copies/$(printf "%05d.png" $j);
    echo cp results/annotated/$i results/copies/$(printf "%05d.png" $j);
    j=$((j+1));
done

# Finally, create the video
ffmpeg -f image2 -i ./results/copies/%05d.png -vf scale=800x450,setsar=1 -c:v libx264 -pix_fmt yuv420p -profile:v main -coder 0 -preset veryslow -crf 22 -threads 0 movie.mp4

#!/bin/bash
# See the README for usage

# This function generates a single image for the given day,
# designed to be run in the background with xargs
function makeImageForDay()
{
    filesOnThisDate=$1
    filename=$2
    dateWithSpaces=$3
    if [ "$dateWithSpaces" == "" ]; then
        # Sometimes xargs has some extra crust at the end of its arg list
        return
    fi

    # echo $filesOnThisDate :: $filename :: $dateWithSpaces # For debugging
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
}

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
    args="$args '\"$filesOnThisDate\"' '\"$filename\"' '\"$dateWithSpaces\"'"
    filenameList="$filenameList $filename"
done

# Run makeImageForDay via xargs
export -f makeImageForDay
# echo $args | xargs -P8 -n3 -I{} bash -c "makeImageForDay {}"

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

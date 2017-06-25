# This file generates a single image for the given day,
# designed to be run in the background with xargs

filesOnThisDate=$1
filename=$2
dateWithSpaces=$3
if [ "$dateWithSpaces" == "" ]; then
    echo "ERROR: xargs didn't pass in arguments correctly."
    exit -1
fi

# echo $filesOnThisDate :: $filename :: $dateWithSpaces # For debugging
echo montage -geometry 640x480 -background Black $filesOnThisDate results/montages/$filename
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

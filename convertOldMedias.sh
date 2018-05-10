#! /bin/bash

#########################################################
#                                                       #
# resizePictures.sh                                     #
#                                                       #
# Author: Damien Broqua <contact@darkou.fr>             #
# Github: https://github.com/Dbroqua/resizePictures     #
# Licence: Apache License 2.0                           #
#                                                       #
# Requirement:                                          #
# - imagemagick                                         #
#                                                       #
#########################################################

DEST='resized'
OPTIONS='-depth 8 -quality 80 -strip -interlace Plane'

# Defining some colors for log()
RED="\E[31m"
BLUE="\E[44m"
GREEN="\E[92m"
BOLD="\033[4m"
RESET="\033[0m"


# If destination does not exists, create it
if [ ! -d ${DEST} ] ; then
    mkdir ${DEST}
fi

# For each files
for image in {*.JPG,*.jpg} ; do
    if [ ! -f ${image} ] ; then
        echo -e "${RED}# No file found in ${PWD}${RESET}"
        continue
    fi

    # Convert
    echo -e "${GREEN}Converting ${image}${RESET}"

    # Extract image dimensions
    WIDTH=`identify -format "%[fx:w]" ${image}`
    HEIGHT=`identify -format "%[fx:h]" ${image}`

    WIDTH=$((${WIDTH}-20))
    HEIGHT=$((${HEIGHT}-45))

    convert ${OPTIONS} -crop ${WIDTH}x${HEIGHT}+10+10 +repage ${image} ${DEST}/${image}
done

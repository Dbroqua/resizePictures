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
# Usage:                                                #
# - create logo.png in ~/templates                      #
# - run resizePictures.sh in wanted directory           #
# All jpg of the current folder wil be resized and      #
# stored in <currentfolder>/resized                     #
# If cover.jpg found, file will be converted in other   #
# size and without logo (for my wordpress theme).       #
#                                                       #
#########################################################

# Your choices
MAXWIDTH=800
MAXHEIGHT=600
COVERWIDTH=520
COVERHEIGHT=245

# Defining some generic variables
COVERFILE="cover.jpg"
COVERRATIO=$((${COVERWIDTH}/${COVERHEIGHT}))
LOGO=~/template/logo.png
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
for image in {*.jpg,*.JPG} ; do
    if [ ! -f ${image} ] ; then
        echo -e "${RED}# No file found in ${PWD}${RESET}"
        continue
    fi

    # Convert covert
    if [ "${image}" == "${COVERFILE}" ] ; then
        echo -e "${GREEN}Converting cover file${RESET}"

        # Extract image dimensions
        WIDTH=`identify -format "%[fx:w]" ${image}`
        HEIGHT=`identify -format "%[fx:h]" ${image}`

        # Compute image ratio
        IMAGERATIO=$((${WIDTH}/${HEIGHT}))

        # Define temporary image size (used for crop)
        TMPWIDTH=${WIDTH}
        TMPHEIGHT=${HEIGHT}

        # Compute temporary with or height to crop correctly image
        if [ "${COVERRATIO}" -gt "${IMAGERATIO}" ] ; then
            TMPHEIGHT=$((${WIDTH}*${COVERHEIGHT}/${COVERWIDTH}))
        else
            TMPWIDTH=$((${HEIGHT}*${COVERWIDTH}/${COVERHEIGHT}))
        fi

        # Crop image with the good ratio
        convert -gravity Center -crop ${TMPWIDTH}x${TMPHEIGHT}+0+0 +repage ${image} /tmp/${image}

        # Rezise cover and save it
        convert ${OPTIONS} -resize ${COVERWIDTH}x${COVERHEIGHT} /tmp/${image} ${DEST}/${image}

        # Remove temporary file
        rm /tmp/${image}
    else
        echo -e "${RED}Converting image ${image}${RESET}"

        convert -resize ${MAXWIDTH}x${MAXHEIGHT} ${image} ${DEST}/${image}
        composite ${OPTIONS} -gravity SouthEast ${LOGO} ${DEST}/${image} ${DEST}/${image}
    fi
done

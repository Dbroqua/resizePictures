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
COVERRATIO=`bc -l <<< "${COVERWIDTH}/${COVERHEIGHT}"`
LOGO=~/template/logo.png
IMAGERATIO=`bc -l <<< "${MAXWIDTH}/${MAXHEIGHT}"`
DEST='resized'
OPTIONS='-depth 8 -quality 90 -strip -interlace Plane'
BORDERWIDTH=12
BORDERTHINWIDTH=1
BORDERTHINPLACEMENT=8

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
  if [ "${image}" != "*.JPG" ] && [ "${image}" != "*.jpg" ] ; then
    if [ ! -f "${image}" ] ; then
      echo -e "${RED}# ${image} is not a valid image file in ${PWD}${RESET}"
      continue
    fi

    # Extract image dimensions
    WIDTH=`identify -format "%[fx:w]" ${image}`
    HEIGHT=`identify -format "%[fx:h]" ${image}`

    # Compute image ratio
    TMPIMAGERATIO=`bc -l <<< "${WIDTH}/${HEIGHT}"`

    # Define image size
    NEWWIDTH=${WIDTH}
    NEWHEIGHT=${HEIGHT}

    # Compute new image size based on image type
    if [ "${image}" == "${COVERFILE}" ] ; then
      # Compute temporary with or height to crop correctly image
      if [ "${COVERRATIO}" -gt "${TMPIMAGERATIO}" ] ; then
        NEWHEIGHT=$((${WIDTH}*${COVERHEIGHT}/${COVERWIDTH}))
      else
        NEWWIDTH=$((${HEIGHT}*${COVERWIDTH}/${COVERHEIGHT}))
      fi
    else
      # Compute temporary with or height to crop correctly image
      RATIO=`echo ${IMAGERATIO}'<'${TMPIMAGERATIO} | bc -l`
      if [ ${RATIO} -eq 1 ] ; then
        NEWWIDTH=${MAXWIDTH}
        NEWHEIGHT=`LC_NUMERIC="en_US.UTF-8" printf "%.0f" $(bc -l <<< "scale=1; ${HEIGHT}*${NEWWIDTH}/${WIDTH}")`
      else
        NEWHEIGHT=${MAXHEIGHT}
        NEWWIDTH=`LC_NUMERIC="en_US.UTF-8" printf "%.0f" $(bc -l <<< "scale=1; ${WIDTH}*${NEWHEIGHT}/${HEIGHT}")`
      fi
    fi

    # Convert cover
    if [ "${image}" == "${COVERFILE}" ] ; then
      echo -e "${GREEN}Converting cover file${RESET}"

      # Crop image with the good ratio
      convert -gravity Center -crop ${NEWWIDTH}x${NEWHEIGHT}+0+0 +repage ${image} /tmp/${image}

      # Rezise cover and save it
      convert ${OPTIONS} -resize ${COVERWIDTH}x${COVERHEIGHT} /tmp/${image} ${DEST}/${image}

      # Remove temporary file
      rm /tmp/${image}
    else
      echo -e "${RED}Converting image ${image}${RESET}"
      echo -e "  -> ${BLUE}Create JPG version${RESET}"

      # Compute positions for black border
      BORDERUPPERLEFT=$((${BORDERWIDTH}/2)),$((${BORDERWIDTH}/2))
      BORDERLOWERLEFT=$((${BORDERWIDTH}/2)),$((${NEWHEIGHT} - ${BORDERWIDTH}/2))
      BORDERLOWERRIGHT=$((${NEWWIDTH} - ${BORDERWIDTH}/2)),$((${NEWHEIGHT} - ${BORDERWIDTH}/2))
      BORDERUPPERRIGHT=$((${NEWWIDTH} - ${BORDERWIDTH}/2)),$((${BORDERWIDTH}/2))

      # Compute positions for white border
      THINBORDERUPPERLEFT=${BORDERTHINPLACEMENT},${BORDERTHINPLACEMENT}
      THINBORDERLOWERLEFT=${BORDERTHINPLACEMENT},$((${NEWHEIGHT}-${BORDERTHINPLACEMENT} ))
      THINBORDERLOWERRIGHT=$((${NEWWIDTH}-${BORDERTHINPLACEMENT} )),$((${NEWHEIGHT}-${BORDERTHINPLACEMENT} ))
      THINBORDERUPPERRIGHT=$((${NEWWIDTH}-${BORDERTHINPLACEMENT} )),${BORDERTHINPLACEMENT}
      
      # resize and add border on image
      convert -resize ${NEWWIDTH}x${NEWHEIGHT} \
      "${image}" \
      -fill transparent -stroke black -strokewidth ${BORDERWIDTH} -draw "stroke-linecap square path 'M $((${BORDERWIDTH}/2)),0 L ${BORDERLOWERLEFT} L ${BORDERLOWERRIGHT} L ${BORDERUPPERRIGHT} L ${BORDERUPPERLEFT} Z'" \
      -fill transparent -stroke white -strokewidth ${BORDERTHINWIDTH} -draw "stroke-linecap square path 'M ${THINBORDERUPPERLEFT} L ${THINBORDERLOWERLEFT} L ${THINBORDERLOWERRIGHT} L ${THINBORDERUPPERRIGHT} L ${THINBORDERUPPERLEFT} Z'" \
      "${DEST}/${image}"

      # Add logo on imagedow
      composite ${OPTIONS} -gravity SouthEast "${LOGO}" "${DEST}/${image}" "${DEST}/${image}"

      # Create same version but in PNG and with box shadow
      echo -e "  -> ${BLUE}Create PNG version${RESET}"
      filename=$(basename -- "${image}")
      extension="${filename##*.}"
      filename="${filename%.*}"

      convert -resize ${NEWWIDTH}x${NEWHEIGHT} \
      "${image}" \
      -fill transparent -stroke black -strokewidth ${BORDERWIDTH} -draw "stroke-linecap square path 'M $((${BORDERWIDTH}/2)),0 L ${BORDERLOWERLEFT} L ${BORDERLOWERRIGHT} L ${BORDERUPPERRIGHT} L ${BORDERUPPERLEFT} Z'" \
      -fill transparent -stroke white -strokewidth ${BORDERTHINWIDTH} -draw "stroke-linecap square path 'M ${THINBORDERUPPERLEFT} L ${THINBORDERLOWERLEFT} L ${THINBORDERLOWERRIGHT} L ${THINBORDERUPPERRIGHT} L ${THINBORDERUPPERLEFT} Z'" \
      \( +clone -background black -shadow 80x3+2+2 \) \
      +swap -background transparent -layers merge +repage \
      "${DEST}/${filename}.png"

      # Add logo on imagedow
      composite ${OPTIONS} -gravity SouthEast "${LOGO}" "${DEST}/${filename}.png" "${DEST}/${filename}.png"
    fi
  fi
done

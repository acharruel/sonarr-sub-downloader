#!/bin/bash
set -e
echo `dirname $0`
declare LOG_FILE=`dirname $0`/sub-downloader.log
declare WANTED_FILE=`dirname $0`/wanted/subs.wanted
declare OPTIONS='--opensubtitles USERNAME PASSWORD'

# Radarr does not show the stdout as part of the log information displayed by the system,
# So I decided to store the log information by my own.
function doLog {
    echo -e $1
    echo -e $1 >> $LOG_FILE
}

declare LANGUAGES="en fr"

doLog "###### Process started at: $(date) ######"

declare EPISODE_PATH=${radarr_movie_path}
declare EVENT=${radarr_eventtype}

if [ $EVENT == "Test" ]; then
    doLog "Test from radarr"
    exit 0
fi

if [[ -z $EPISODE_PATH ]]; then
    doLog "radarr_movie_path environment variable not found"
    exit 1
fi

doLog "Looking for subtitles for: ${EPISODE_PATH}"

doLog "Executing subliminal"
for lang in $LANGUAGES; do
    subliminal ${OPTIONS} download -l ${lang} "${EPISODE_PATH}" >> $LOG_FILE 2>&1
done

# Look for not found subtitles
declare LANG_ARRAY=($(echo ${LANGUAGES} | sed "s/-l //g"))

for LANG in "${LANG_ARRAY[@]}"; do
    SUB_FILE=$(echo $EPISODE_PATH | sed "s/...$/${LANG}\.srt/g")
    if [[ ! -f $SUB_FILE ]]; then
        doLog "Subtitle ${SUB_FILE} not found, adding it to wanted"
        echo $EPISODE_PATH:$SUB_FILE >> ${WANTED_FILE}
    fi
done


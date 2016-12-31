#!/bin/bash
EXECUTION_STARTTIME=$(date +%s)
MODIFIED_FILESCOUNT=0
TYPE=""
FORCE="false"
VERBOSE="false"
PATTERN="*"
FILE_FORMAT="%Y_%m_%d+%H.%M.%S"
PLATFORM="$(uname -s)"

for i in "$@"
do
    case $i in
        -e=*|--extension=*)
        TYPE="${i#*=}"
        PATTERN="*.$TYPE"
        shift
        ;;
        -v|--verbose)
        VERBOSE="true"
        shift
        ;;
        -p=*|--pattern=*)
        PATTERN="${i#*=}"
        shift
        ;;
        -b=*|--before=*)
        BEFORE="${i#*=}"
        shift
        ;;
        -a=*|--after=*)
        AFTER="${i#*=}"
        shift
        ;;
        --format=*)
        FILE_FORMAT="${i#*=}"
        shift
        ;;
        -f|--force)
        FORCE="true"
        shift
        ;;
        *)
        ;;
    esac
done


if ! ls $PATTERN 1> /dev/null 2>&1
then
    echo "No files found with given pattern or extension: $PATTERN"
    exit 1
fi

FILESCOUNT=$(ls $PATTERN | wc -l)


makeSequential () {
    BASENAME=$1
    ORIGINAL_NAME=$2
    EXTENSION=$(awk -F . '{print $NF}' <<< "$ORIGINAL_NAME")
    if [ $EXTENSION != $ORIGINAL_NAME ]; then EXTENSION=".$EXTENSION"; else EXTENSION=""; fi
    COUNT=${3:-1}
    if [ ! -e "$BASENAME($COUNT)$EXTENSION" ] 
    then
        (( MODIFIED_FILESCOUNT++ ))
        mv -n "x" "$BASENAME($COUNT)$EXTENSION"
        if [ $VERBOSE = "true" ] && [ -n "$ORIGINAL_NAME" ]; then echo "$ORIGINAL_NAME => $BASENAME($COUNT)$EXTENSION"; fi
    else 
        (( COUNT++ ))
        makeSequential $BASENAME $ORIGINAL_NAME $COUNT
    fi
}

for FILE in $PATTERN;
do
FILEBASE="${FILE%.*}"
EXTENSION=$(awk -F . '{print $NF}' <<< "$FILE")
if [ $EXTENSION != $FILE ]; then EXTENSION=".$EXTENSION"; else EXTENSION=""; fi

if [ "$BEFORE" != "" ] && [ "$AFTER" != "" ] 
then
    BASENAME="$BEFORE$FILEBASE$AFTER"
elif [ "$BEFORE" != "" ] 
then
    BASENAME="$BEFORE$FILEBASE"
elif [ "$AFTER" != "" ]
then 
    BASENAME="$FILEBASE$AFTER"
else
    if [ $PLATFORM = "Darwin" ]
    then
        BASENAME=$(stat -f "%Sm" -t "$FILE_FORMAT" "$FILE")
    else
        BASENAME=$(date "+$FILE_FORMAT" -r "$FILE")
    fi
fi

ORDER=$(awk -F'[(|)]' '{print $2}' <<< "$FILE")
ORIGINAL_NAME="$FILE"

if [ -n "$ORDER" ]; then ORDER="($ORDER)"; else ORDER=""; fi

if [ "$FILE" != "${BASENAME}${ORDER}${EXTENSION}" ] || [ "$FORCE" = "true" ]
then
    mv -n "$FILE" "x"
    if [ ! -e "${BASENAME}${EXTENSION}" ]
    then
        (( MODIFIED_FILESCOUNT++ ))
        mv -n "x" "${BASENAME}${EXTENSION}"
        if [ $VERBOSE = "true" ]; then echo "$ORIGINAL_NAME => ${BASENAME}${EXTENSION}"; fi
    else
        makeSequential $BASENAME $ORIGINAL_NAME
    fi
fi

done

EXECUTION_ENDTIME=$(date +%s)
EXECUTION_TIME=$(( $EXECUTION_ENDTIME-$EXECUTION_STARTTIME ))
echo "$FILESCOUNT files found, $MODIFIED_FILESCOUNT files renamed in $EXECUTION_TIME seconds"
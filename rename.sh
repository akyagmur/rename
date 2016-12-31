#!/bin/bash
EXECUTION_STARTTIME=$(date +%s)
MODIFIED_FILESCOUNT=0
TYPE="jpg"
FORCE="false"
VERBOSE="false"
PATTERN="*.$TYPE"
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
    EXTENSION=$2
    INPUT=$3
    COUNT=$4
    ORIGINAL_NAME=$5

    if [ ! -e "$BASENAME($COUNT).$EXTENSION" ] 
    then
        (( MODIFIED_FILESCOUNT++ ))
        mv -n "$INPUT" "$BASENAME($COUNT).$EXTENSION"
        if [ $VERBOSE = "true" ] && [ -n "$ORIGINAL_NAME" ]; then echo "$ORIGINAL_NAME => $BASENAME($COUNT).$EXTENSION"; fi
    else 
        (( COUNT++ ))
        makeSequential $BASENAME $EXTENSION $INPUT $COUNT $ORIGINAL_NAME
    fi
}

for FILE in $PATTERN;
do
EXTENSION=$(awk -F . '{print $NF}' <<< "$FILE")
if [ $PLATFORM = "Darwin" ]
then
    BASENAME=$(stat -f "%Sm" -t "$FILE_FORMAT" "$FILE")
else
    BASENAME=$(date "+$FILE_FORMAT" -r "$FILE")
fi
ORDER=$(awk -F'[(|)]' '{print $2}' <<< "$FILE")
ORIGINAL_NAME="$FILE"

if [ -n "$ORDER" ]; then ORDER="($ORDER)"; else ORDER=""; fi

if [ "$FILE" != "${BASENAME}${ORDER}.${EXTENSION}" ] || [ "$FORCE" = "true" ]
then
    mv -n "$FILE" "x"
    if [ ! -e "${BASENAME}.${EXTENSION}" ]
    then
        (( MODIFIED_FILESCOUNT++ ))
        mv -n "x" "${BASENAME}.${EXTENSION}"
        if [ $VERBOSE = "true" ]; then echo "$ORIGINAL_NAME => ${BASENAME}.${EXTENSION}"; fi
    else
        makeSequential $BASENAME $EXTENSION "x" "1" $ORIGINAL_NAME
    fi
fi

done

EXECUTION_ENDTIME=$(date +%s)
EXECUTION_TIME=$(( $EXECUTION_ENDTIME-$EXECUTION_STARTTIME ))
echo "$FILESCOUNT files found, $MODIFIED_FILESCOUNT files renamed in $EXECUTION_TIME seconds"
#!/bin/bash
EXECUTION_STARTTIME=$(date +%s)
MODIFIED_FILESCOUNT=0
PATTERN="*"
DATE_FORMAT="%Y_%m_%d+%H.%M.%S"
PLATFORM="$(uname -s)"
NOW=$(date "+%Y:%m:%d_%H:%M:%S")

for i in "$@"; do
    case $i in
        -e=*|--extension=*)
        GIVEN_EXTENSION="${i#*=}"
        PATTERN="*.$GIVEN_EXTENSION"
        shift
        ;;
        -v|--verbose)
        VERBOSE=false
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
        DATE_FORMAT="${i#*=}"
        shift
        ;;
        -f|--force)
        FORCE=false
        shift
        ;;
        --backup)
        BACKUP=false
        shift
        ;;
        --restore)
        RESTORE=false
        shift
        ;;
        *)
        ;;
    esac
done

if ! $RESTORE; then
    if ! $(ls .backup* 1> /dev/null  2>&1) ; then
        echo "No backup file found at this folder."
        exit 1
    fi

    PS3="Please choose backup file: "
    BACKUP_FILES=($(ls .backup*))
    BACKUP_FILES+=("Quit")
    select BACKUP_FILE in "${BACKUP_FILES[@]}"; do
        case $BACKUP_FILE in
            "$BACKUP_FILE")
                if [ "$BACKUP_FILE" = "Quit" ]; then
                    exit 1
                fi

                while read line; do
                    ORDER="1"
                    for word in $line; do
                        if [ $ORDER = "1" ]; then
                            LAST_FILENAME="$word"
                        else 
                            if [ -e $LAST_FILENAME ] ; then
                                mv "$LAST_FILENAME" "$word"
                            fi
                        fi
                        (( ORDER++ ))
                    done
                done < $BACKUP_FILE

                FILES_COUNT=$(wc -l < $BACKUP_FILE)
                rm "$BACKUP_FILE"
                EXECUTION_ENDTIME=$(date +%s)
                EXECUTION_TIME=$(( $EXECUTION_ENDTIME-$EXECUTION_STARTTIME ))
                echo "$FILES_COUNT files renamed from backup in $EXECUTION_TIME seconds"
                exit 1
                ;;
            *) echo "Invalid option";;
        esac
    done
fi

if ! ls $PATTERN 1> /dev/null 2>&1; then
    echo "No files found with given pattern or extension: $PATTERN"
    exit 1
fi

FILESCOUNT=$(ls $PATTERN | wc -l)

make_sequential () {
    BASENAME=$1
    ORIGINAL_FILE_FULLNAME=$2
    EXTENSION=$(awk -F . '{print $NF}' <<< "$ORIGINAL_FILE_FULLNAME")
    if [ $EXTENSION != $ORIGINAL_FILE_FULLNAME ]; then EXTENSION=".$EXTENSION"; else EXTENSION=""; fi
    COUNT=${3:-1}
    if [ ! -e "$BASENAME($COUNT)$EXTENSION" ] ; then
        (( MODIFIED_FILESCOUNT++ ))
        mv -n "x" "$BASENAME($COUNT)$EXTENSION"
        if ! $BACKUP ; then echo -e "\t$BASENAME($COUNT)$EXTENSION\t$ORIGINAL_FILE_FULLNAME" >> ".backup$NOW"; fi
        if ! $VERBOSE && [ -n "$ORIGINAL_FILE_FULLNAME" ]; then echo "$ORIGINAL_FILE_FULLNAME => $BASENAME($COUNT)$EXTENSION"; fi
    else 
        (( COUNT++ ))
        make_sequential $BASENAME $ORIGINAL_FILE_FULLNAME $COUNT
    fi
}

for FILE in $PATTERN; do
    ORIGINAL_FILE_BASENAME="${FILE%.*}"
    EXTENSION=$(awk -F . '{print $NF}' <<< "$FILE")
    
    if [ $EXTENSION != $FILE ]; then EXTENSION=".$EXTENSION"; else EXTENSION=""; fi

    if [ "$BEFORE" != "" ] || [ "$AFTER" != "" ] ; then
        BASENAME="$BEFORE$ORIGINAL_FILE_BASENAME$AFTER"
    else
        if [ $PLATFORM = "Darwin" ] ; then
            BASENAME=$(stat -f "%Sm" -t "$DATE_FORMAT" "$FILE")
        else
            BASENAME=$(date "+$DATE_FORMAT" -r "$FILE")
        fi
    fi

    ORDER=$(awk -F'[(|)]' '{print $2}' <<< "$FILE")
    ORIGINAL_FILE_FULLNAME="$FILE"

    if [ -n "$ORDER" ]; then ORDER="($ORDER)"; else ORDER=""; fi

    if [ "$FILE" != "${BASENAME}${ORDER}${EXTENSION}" ] || ! $FORCE && ! test -d $FILE ; then
        mv -n "$FILE" "x"
        if [ ! -e "${BASENAME}${EXTENSION}" ] ; then
            (( MODIFIED_FILESCOUNT++ ))
            mv -n "x" "${BASENAME}${EXTENSION}"
            if ! $BACKUP ; then echo -e "\t${BASENAME}${EXTENSION}\t$ORIGINAL_FILE_FULLNAME" >> ".backup$NOW"; fi
            if ! $VERBOSE ; then echo "$ORIGINAL_FILE_FULLNAME => ${BASENAME}${EXTENSION}"; fi
        else
            make_sequential $BASENAME $ORIGINAL_FILE_FULLNAME
        fi
    fi
done

EXECUTION_ENDTIME=$(date +%s)
EXECUTION_TIME=$(( $EXECUTION_ENDTIME-$EXECUTION_STARTTIME ))
echo "$FILESCOUNT files found, $MODIFIED_FILESCOUNT files renamed in $EXECUTION_TIME seconds"
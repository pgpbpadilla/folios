#!/bin/bash

function get_column {
    local COL_NUM=$2
    local FILE=$1

    cat $FILE | cut -d',' -f$COL_NUM
}

function list2file {
    local FILE_NAME=$(pwgen 5 1).tmp
    touch $FILE_NAME # create file with random name
    
    for line in $1
    do
        echo "$line" >> $FILE_NAME
    done
    
    local SORTED_FILE=$FILE_NAME.sorted
    cat $FILE_NAME | uniq | sort > $SORTED_FILE
    echo $SORTED_FILE
}

function get_intersection {
    local COL1=$1
    local COL2=$2
    
    local TMPF1=$(list2file "${COL1}")
    local TMPF2=$(list2file "${COL2}")

    comm -12 $TMPF1 $TMPF2
}

function lookup {
    local FILE=$1
    local FOLIO=$2
    local COL_NUMS=$3

    grep $FOLIO $FILE | cut -d',' -f$COL_NUMS
}


## Main program

ALL_FILE=$1
MONTH_FILE=$2

ALL_FOLIOS=$(get_column "${ALL_FILE}" 1)
MONTH_FOLIOS=$(get_column "${MONTH_FILE}" 2)

FOLIOS=$(get_intersection "${ALL_FOLIOS}" "${MONTH_FOLIOS}")


for folio in $FOLIOS
do
    echo "Extract col2 for $folio from file: ${ALL_FILE}"
    lookup $ALL_FILE ${folio} 2
done

for folio in $FOLIOS
do
    echo "Extract col2 and col3 for $folio from file: ${MONTH_FILE}"
    lookup $MONTH_FILE ${folio} 1,3
done

#!/bin/bash

function get_column {
    local COL_NUM=$2
    local FILE=$1

    cat $FILE | cut -d',' -f$COL_NUM
}

function list2file {
    local FILE_NAME=$(pwgen 5 1).tmp
    touch $FILE_NAME # create file with random name
    
    local COL=$1
    
    for line in $COL
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
    
    comm -12 $TMPF1 $TMPF2 # Only keep the intersection
}

function lookup {
    local FILE=$1
    local FOLIO=$2
    local COL_NUMS=$3

    grep $FOLIO $FILE | cut -d',' -f$COL_NUMS
}


## Main program

# e.g. ./join file1 file2
ALL_FILE=$1 # First argument in the program call, i.e. $1 => file1
MONTH_FILE=$2
OUTPUT=$3

ALL_FOLIOS=$(get_column "${ALL_FILE}" 1)
MONTH_FOLIOS=$(get_column "${MONTH_FILE}" 6)

echo "all="${ALL_FOLIOS}
echo "month="${MONTH_FOLIOS}

FOLIOS=$(get_intersection "${ALL_FOLIOS}" "${MONTH_FOLIOS}")

echo $FOLIOS

function aggregate_values {
    for folio in $FOLIOS
    do
        COLS_ALL=$(lookup $ALL_FILE ${folio} 1,4,6,8)
        COLS_MONTH=$(lookup $MONTH_FILE ${folio} 5)
        echo "${COLS_ALL},${COLS_MONTH}"
    done
}

# Result sample: 
# folioplus, clv_statussolicitud, pagado, fecha_afiliacion, foliotarjeta, stasol
# 1 (online), 4 (online),         8 (online), 6 (online),   6 (por mes),  5(por mes)

aggregate_values > $OUTPUT

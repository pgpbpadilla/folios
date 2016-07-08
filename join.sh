#!/bin/bash

function print {
    for line in $1
    do
        echo $line
    done
}

function get_column {
    local COL_NUM=$2
    local FILE=$1

    print $(cat $FILE | cut -d',' -f$COL_NUM)
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
    
    local TMPF1=$(list2file $COL1)
    local TMPF2=$(list2file $COL2)

    local INTERSECTION=$(comm -12 $TMPF1 $TMPF2)

    print $INTERSECTION
}

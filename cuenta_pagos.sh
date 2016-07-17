#!/bin/bash

function get_folios {
    INPUT_DIR=$1
    OUTPUT=folios_mes-$(pwgen 6 1).tmp

    if ! cat $INPUT_DIR/*.csv | cut -d',' -f 1 | sort | uniq | head -n -1 > $OUTPUT;
    then
	echo "Error processing input files"
    fi
    
    echo $OUTPUT
}

function count_payments {

    declare -A months
    months=(
	["03"]="Marzo"
	["04"]="Abril"
	["05"]="Mayo"
	["06"]="Junio"
	["07"]="Julio"
	["08"]="Agosto"
	["09"]="Septiembre"
	["10"]="Octubre"
	["11"]="Noviembre"
	["12"]="Diciembre"
    )
    declare -A last_payment
    
    local INPUT_DIR=$1
    local FOLIOS=$(get_folios $INPUT_DIR)

    echo "folio,cuenta_pagos,fecha_ultimo_pago"
    
    for folio in $(cat $FOLIOS)
    do
	local COUNT=0
	# echo "looking for $folio ..."
	for month_file in $(ls $INPUT_DIR/*.csv);
	do
	    # e.g. result03.csv => result03
	    local BASE_NAME=$(echo "${month_file}" | cut -d'.' -f1)
	    # e.g., result03 => 03
	    local MONTH_IDX=${BASE_NAME: -2}
	    # echo "... in file: $month_file"
	    if grep -q $folio "${month_file}"; then
		COUNT=$((COUNT+1))
		last_payment["$folio"]=${months[$MONTH_IDX]}
	    fi
	done
	# echo -n "Folio: $folio, "
	# echo -n "count: $COUNT, "
	# echo "last: ${last_payment["$folio"]}"
	echo "$folio,$COUNT,${last_payment["$folio"]}"
    done
}


# folio, cuenta_pagos, fecha_ultimo_pago
# 123,   4,            Marzo
# 666,   9,            Diciembre # Activo
# 333,   3,            Julio # Inactivo
# 444,   3,            Diciembre # 

count_payments $@ > cuenta_pagos-$(pwgen 7 1).csv

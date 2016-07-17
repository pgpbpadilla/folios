#!/bin/bash

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
    declare -A payment_count
    
    local INPUT_DIR=$1

    echo "folio,cuenta_pagos,fecha_ultimo_pago"
    
    for month_file in $(ls $INPUT_DIR/*.csv);
    do
	for line in $(cat ${month_file});
	do
	    local folio=$(echo $line | cut -d',' -f1)

	    # e.g. result03.csv => result03
	    local BASE_NAME=$(echo "${month_file}" | cut -d'.' -f1)
	    # e.g., result03 => 03
	    local MONTH_IDX=${BASE_NAME: -2}

	    [ ! "${payment_count["$folio"]}" ] && payment_count["$folio"]=0
	    
	    local COUNT="${payment_count["$folio"]}"
	    # echo "COUNT: $COUNT"
	    payment_count["$folio"]=$((COUNT+1))
	    last_payment["$folio"]=${months[$MONTH_IDX]}

	done
    done

    for key in "${!payment_count[@]}"
    do
	echo "$key,${payment_count["$key"]},${last_payment["$key"]}"
    done
}

# folio, cuenta_pagos, fecha_ultimo_pago
# 123,   4,            Marzo
# 666,   9,            Diciembre # Activo
# 333,   3,            Julio # Inactivo
# 444,   3,            Diciembre # 

count_payments $@ > cuenta_pagos-$(pwgen 7 1).csv

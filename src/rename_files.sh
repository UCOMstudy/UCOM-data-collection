#!/usr/bin/env bash

rename_files () {
    if [ $1 == '.' ]; then FOLDER_PATH=$(pwd); else FOLDER_PATH=$1; fi
    echo "Data path: ${FOLDER_PATH}"
    
    for dir in ${FOLDER_PATH}/*; do
        base=$(basename ${dir})
        choice_file=${dir}/${base}_Choice
        numeric_file=${dir}/${base}_Numeric
        if [ -f ${choice_file}.csv ]; then
            echo "${choice_file}.csv -->  ${choice_file}Values.csv;"
            mv ${choice_file}.csv ${choice_file}Values.csv;
        fi;

        if [ -f ${numeric_file}.csv ]; then
            echo "${numeric_file}.csv -->  ${numeric_file}Values.csv;"
            mv ${numeric_file}.csv ${numeric_file}Values.csv;
        fi; 
    done;
}   
# for dir in 

rename_files $1

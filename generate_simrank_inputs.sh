#!/bin/bash

STORE_MAX_ITERATIONS_FILE="./max_iterations.txt"
STORE_CONFIDENCE_VALUE_FILE="./confidence_parameter.txt"


#clear file
dd if=/dev/null of=$STORE_MAX_ITERATIONS_FILE
dd if=/dev/null of=$STORE_CONFIDENCE_VALUE_FILE


for i in range {0..10}
do
    # MAX ITERATIONS
    max_iterations=$(( $RANDOM%1000 ))
    echo $max_iterations >> $STORE_MAX_ITERATIONS_FILE

    #confidence parameter
    c_value=$(( $RANDOM%1000 ))
    store="0.$c_value"
    echo $store >> $STORE_CONFIDENCE_VALUE_FILE
done


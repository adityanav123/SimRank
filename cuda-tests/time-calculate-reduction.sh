#!/bin/bash

n=1000
declare -a a=()
for i in {0..100};
do
    tmp=($(( $RANDOM % 10000 )))
    a+=($tmp)
done
#  echo ${a[@]}
for i in "${a[@]}"
do
    rm -rf test.txt
    touch test.txt
    echo $i >> test.txt
    ./parallel_reduction
done

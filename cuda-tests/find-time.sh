#!/bin/bash

n=1000
declare -a a=()
for i in {0..1000};
do
    tmp=($(( $RANDOM % 3000 )))
    a+=($tmp)
done
#  echo ${a[@]}
for i in "${a[@]}"
do
    rm -rf test.txt
    touch test.txt
    echo $i >> test.txt
    ./in-neighbour-calculation
done

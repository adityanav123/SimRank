#!/bin/bash

output_file="../data/simrankConfig.txt"

echo "generating random values.."
iter="$(( $RANDOM % 1000 ))"
conf="0.$(( $RANDOM % 999 ))"


#append to file
echo "$iter $conf" >> $output_file


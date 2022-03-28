#!/bin/bash

GENERATE_GRAPH_FOLDER="./tests/"
GRAPH_GENERATION_MODEL=$1

echo "Generate New Graph? [Y/n]"
read var
if [[ -z "$var" || $var -eq "Y" ]] # if any input not given
then
    cd $GENERATE_GRAPH_FOLDER
    python3 $GRAPH_GENERATION_MODEL
    cd ..
fi
clear
exit
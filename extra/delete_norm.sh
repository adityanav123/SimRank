#!/bin/bash

file_="../data/l1Norm.txt"

#deleting file
if [[ -f "$file_" ]]
then
	rm -rf $file_
fi


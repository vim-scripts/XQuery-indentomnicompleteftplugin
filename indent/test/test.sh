#!/bin/bash

file=1.diff

if [ -s $file ]
then 
    echo "$file exists and is *NOT* empty!"
else 
    echo "$file exists and IS empty"
fi

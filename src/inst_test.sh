#!/bin/bash

rm -f a.out && gcc hxd32.c

for f in $2/*.elf; do
    echo "Testing $f ...";

    prefix=`echo $f | sed -r 's|(.*).elf|\1|g'`

    ./a.out $1 $prefix.iram $prefix.dram $prefix.reference_output $prefix.bin $prefix.txt $prefix.diff
done

rm -f a.out

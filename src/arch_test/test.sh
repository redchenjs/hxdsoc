#!/bin/bash

gcc hxd32.c -o hxd32

for f in $2/*.elf; do
    echo "Testing $f ...";

    prefix=`echo $f | sed -r 's|(.*).elf|\1|g'`

    ./hxd32 $1 $prefix.iram $prefix.dram $prefix.reference_output $prefix.bin $prefix.txt $prefix.diff
done

rm -f hxd32

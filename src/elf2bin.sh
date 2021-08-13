#!/bin/bash

for f in $1/*.elf; do
    echo "Processing $f ...";

    prefix=`echo $f | sed -r 's|(.*).elf|\1|g'`

    riscv32-unknown-elf-objcopy -O binary -R .data -R .bss $f $prefix.iram
    sed '$ s/\x00*$//' $prefix.iram > $prefix.iram.stripped
    mv $prefix.iram.stripped $prefix.iram

    riscv32-unknown-elf-objcopy -O binary -j .data -j .bss $f $prefix.dram
    sed '$ s/\x00*$//' $prefix.dram > $prefix.dram.stripped
    mv $prefix.dram.stripped $prefix.dram
done

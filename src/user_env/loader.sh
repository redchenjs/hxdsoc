#!/bin/bash

gcc hxd32.c -o hxd32

./hxd32 $1 main.iram main.dram main.out

rm -f hxd32

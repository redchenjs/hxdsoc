/*
 * start.S
 *
 *  Created on: 2021-08-18 16:50
 *      Author: Jack Chen <redchenjs@live.com>
 */

    .section .init
    .global _start
    .type   _start, @function

_start:
    .option push
    .option norelax
    la gp, __global_pointer$    # global pointer
    .option pop
    la sp, __stack_pointer$     # stack pointer

    li a0, 0                    # argc = 0
    li a1, 0                    # argv = 0

    call main                   # main function

    li t0, 0x10000000           # instruction trap
    jr t0

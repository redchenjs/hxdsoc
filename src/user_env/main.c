/*
 * main.c
 *
 *  Created on: 2021-08-17 15:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#include "main.h"
#include "uart.h"

uint32_t ctrl_0 = 0x00000000;
uint32_t ctrl_1 = 0x00000000;

uart_ctrl_0_t *p_ctrl_0 = (uart_ctrl_0_t *)&ctrl_0;
uart_ctrl_1_t *p_ctrl_1 = (uart_ctrl_1_t *)&ctrl_1;

ssize_t _read(int fd, void *ptr, size_t len)
{
    return uart_read(ptr, len);
}

ssize_t _write(int fd, const void *ptr, size_t len)
{
    return uart_write(ptr, len);
}

int puts(const char *s)
{
    for (int i = 0; s[i] != 0x00; i++) {
        _write(0, s + i, 1);
    }

    _write(0, "\n", 1);
}

int main(void)
{
    p_ctrl_0->baud  = CPU_FREQ / UART_BAUD - 1;
    p_ctrl_1->rst_n = 1;

    UART_REG_CTRL_0 = ctrl_0;
    UART_REG_CTRL_1 = ctrl_1;

    printf("Hello World!\r\n");

    while (1) {
        _read(0, &ctrl_1, 1);
        _write(0, &ctrl_1, 1);
    }

    return 0;
}

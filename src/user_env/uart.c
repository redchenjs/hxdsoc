/*
 * uart.c
 *
 *  Created on: 2021-10-24 19:51
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include "main.h"
#include "uart.h"

ssize_t uart_read(void *ptr, size_t len)
{
    uint8_t *data = ptr;
    uint32_t read = 0x00000000;

    for (size_t i = 0; i < len; i++) {
        do {
            read = UART_REG_DATA_RX;
        } while (!(read & BIT8));

        data[i] = read;
    }

    return len;
}

ssize_t uart_write(const void *ptr, size_t len)
{
    const uint8_t *data = ptr;

    for (size_t i = 0; i < len; i++) {
        while (!(UART_REG_DATA_TX & BIT8));

        UART_REG_DATA_TX = data[i];
    }

    return len;
}

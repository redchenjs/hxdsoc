/*
 * uart.h
 *
 *  Created on: 2021-10-24 19:53
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#define UART_BAUD           (921600)

#define UART_REG_BASE       (0x40000000)
#define UART_REG_CTRL_0     (*(volatile uint32_t *)(UART_REG_BASE + 0x00))
#define UART_REG_CTRL_1     (*(volatile uint32_t *)(UART_REG_BASE + 0x04))
#define UART_REG_DATA_TX    (*(volatile uint32_t *)(UART_REG_BASE + 0x08))
#define UART_REG_DATA_RX    (*(volatile uint32_t *)(UART_REG_BASE + 0x0C))

typedef struct {
    uint32_t baud;
} uart_ctrl_0_t;

typedef struct {
    uint8_t rst_n :1;
    uint8_t rsvd_0:7;

    uint8_t rsvd_1;
    uint8_t rsvd_2;
    uint8_t rsvd_3;
} uart_ctrl_1_t;

extern ssize_t uart_read(void *ptr, size_t len);
extern ssize_t uart_write(const void *ptr, size_t len);

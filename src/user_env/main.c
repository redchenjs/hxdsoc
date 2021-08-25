/*
 * main.c
 *
 *  Created on: 2021-08-17 15:25
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>

#define BIT31   0x80000000
#define BIT30   0x40000000
#define BIT29   0x20000000
#define BIT28   0x10000000
#define BIT27   0x08000000
#define BIT26   0x04000000
#define BIT25   0x02000000
#define BIT24   0x01000000
#define BIT23   0x00800000
#define BIT22   0x00400000
#define BIT21   0x00200000
#define BIT20   0x00100000
#define BIT19   0x00080000
#define BIT18   0x00040000
#define BIT17   0x00020000
#define BIT16   0x00010000
#define BIT15   0x00008000
#define BIT14   0x00004000
#define BIT13   0x00002000
#define BIT12   0x00001000
#define BIT11   0x00000800
#define BIT10   0x00000400
#define BIT9    0x00000200
#define BIT8    0x00000100
#define BIT7    0x00000080
#define BIT6    0x00000040
#define BIT5    0x00000020
#define BIT4    0x00000010
#define BIT3    0x00000008
#define BIT2    0x00000004
#define BIT1    0x00000002
#define BIT0    0x00000001

#define CPU_FREQ            (80 * 1000 * 1000)

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

uint32_t ctrl_0 = 0x00000000;
uint32_t ctrl_1 = 0x00000000;

uart_ctrl_0_t *p_ctrl_0 = (uart_ctrl_0_t *)&ctrl_0;
uart_ctrl_1_t *p_ctrl_1 = (uart_ctrl_1_t *)&ctrl_1;

ssize_t _read(int fd, void *ptr, size_t len)
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

ssize_t _write(int fd, const void *ptr, size_t len)
{
    const uint8_t *data = ptr;

    for (size_t i = 0; i < len; i++) {
        while (!(UART_REG_DATA_TX & BIT8));

        UART_REG_DATA_TX = data[i];
    }

    return len;
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

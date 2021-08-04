/*
 * hxd32.c
 *
 *  Created on: 2021-08-04 10:30
 *      Author: Jack Chen <redchenjs@live.com>
 */

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <errno.h>

typedef enum {
    CPU_RST = 0x2a,
    CPU_RUN = 0x2b,
    CONF_WR = 0x2c,
    CONF_RD = 0x2d,
    DATA_WR = 0x2e,
    DATA_RD = 0x2f
} cmd_t;

void cpu_rst(int sfd)
{
    uint8_t send_buff[] = {0x2a};

    write(sfd, send_buff, sizeof(send_buff));

    printf("=> CPU Reset....\n");
}

void cpu_run(int sfd)
{
    uint8_t send_buff[] = {0x2b};

    write(sfd, send_buff, sizeof(send_buff));

    printf("=> CPU Running....\n");
}

void conf_wr(int sfd, uint32_t addr, uint32_t size)
{
    uint32_t send_buff[] = {0x2c000000, addr, size};

    write(sfd, send_buff, sizeof(send_buff));
}

void conf_rd(int sfd, uint32_t *addr, uint32_t *size)
{
    uint32_t recv_buff[2] = {0};
    uint8_t send_buff[] = {0x2d};

    write(sfd, send_buff, sizeof(send_buff));
    read(sfd, recv_buff, sizeof(recv_buff));

    *addr = recv_buff[0];
    *size = recv_buff[1];
}

void data_wr(int sfd, int ifd, uint32_t size)
{
    uint8_t read_buff = 0;
    uint8_t send_buff[] = {0x2e};

    write(sfd, send_buff, sizeof(send_buff));

    lseek(ifd, 0, SEEK_SET);

    for (int i = 0; i < size; i++) {
        read(ifd, &read_buff, 1);
        write(sfd, &read_buff, 1);

        printf(">> SENT: %d%%\r", i * 100 / size);
    }

    printf(">> SENT: 100%%\n");
}

void data_rd(int sfd, int ofd, uint32_t size)
{
    uint8_t read_buff = 0;
    uint8_t send_buff[] = {0x2f};

    write(sfd, send_buff, sizeof(send_buff));

    lseek(ofd, 0, SEEK_SET);

    for (int i = 0; i < size; i++) {
        read(sfd, &read_buff, 1);
        write(ofd, &read_buff, 1);

        printf("<< RECV: %d%%\r", i * 100 / size);
    }

    printf("<< RECV: 100%%\n");
}

int main(int argc, char *argv[])
{
    int sfd, ifd, dfd, rfd, bfd, tfd, ofd;
    struct stat st;
    struct termios conf;
    char data_str[10] = {0};
    char *port = argv[1];
    char *iramfile = argv[2];
    char *dramfile = argv[3];
    char *reffile = argv[4];
    char *binfile = argv[5];
    char *txtfile = argv[6];
    char *outfile = argv[7];
    uint32_t addr = 0x00000000;
    uint32_t size = 0x00000000;
    uint32_t data = 0x00000000;

    if ((sfd = open(port, O_RDWR | O_NOCTTY)) < 0) {
        printf("failed to open port: %s\n", port);

        return -1;
    }

    if ((ifd = open(iramfile, O_RDONLY)) < 0) {
        printf("failed to open input file: %s\n", iramfile);

        return -1;
    }

    if ((dfd = open(dramfile, O_RDONLY)) < 0) {
        printf("failed to open input file: %s\n", dramfile);

        return -1;
    }

    if ((rfd = open(reffile, O_RDONLY)) < 0) {
        printf("failed to open input file: %s\n", reffile);

        return -1;
    }

    if ((bfd = open(binfile, O_CREAT | O_RDWR | O_TRUNC, 0644)) < 0) {
        printf("failed to open output file: %s\n", binfile);

        return -1;
    }

    if ((tfd = open(txtfile, O_CREAT | O_RDWR | O_TRUNC, 0644)) < 0) {
        printf("failed to open output file: %s\n", txtfile);

        return -1;
    }

    if ((ofd = open(outfile, O_CREAT | O_WRONLY | O_TRUNC, 0644)) < 0) {
        printf("failed to open output file: %s\n", outfile);

        return -1;
    }

    conf.c_cflag |= CLOCAL | CREAD | CS8;

    cfsetispeed(&conf, B921600);
    cfsetospeed(&conf, B921600);

    conf.c_cc[VTIME] = 100;

    tcflush(sfd, TCIFLUSH);
    if((tcsetattr(sfd, TCSANOW, &conf)) != 0) {
        printf("failed to set port: %s", port);

        return -1;
    }

    printf("port: %s, baud: 921600 bps\n", port);

    // cpu reset
    cpu_rst(sfd);

    stat(iramfile, &st);
    size = st.st_size;

    // write iram
    conf_wr(sfd, 0x00000000, size - 1);
    data_wr(sfd, ifd, size);

    stat(dramfile, &st);
    size = st.st_size;

    // write dram
    conf_wr(sfd, 0x10000000, size - 1);
    data_wr(sfd, dfd, size);

    // cpu run
    cpu_run(sfd);

    sleep(2);

    // read dram
    conf_wr(sfd, 0x10000000, 0xbff);
    data_rd(sfd, bfd, 0xbff);

    lseek(bfd, 0x10, SEEK_SET);

    read(bfd, &data, 4);
    while (data != 0xdeadbeef) {
        snprintf(data_str, sizeof(data_str), "%08x\n", data);
        write(tfd, data_str, strlen(data_str));
        read(bfd, &data, 4);
    }

    // diff
    lseek(rfd, 0, SEEK_SET);
    lseek(tfd, 0, SEEK_SET);

    char *temp_str_0 = malloc(10);
    char *temp_str_1 = malloc(10);
    char *output_str = malloc(40);
    size_t count = 0;
    while (read(rfd, temp_str_0, 9)) {
        read(tfd, temp_str_1, 9);

        if (strcmp(temp_str_0, temp_str_1)) {
            temp_str_0[8] = 0x00;
            temp_str_1[8] = 0x00;
            sprintf(output_str, "inst_%d: ref: %08s, real: %08s\n", count, temp_str_0, temp_str_1);
            write(ofd, output_str, strlen(output_str));
        }

        count++;
    }

    close(bfd);
    close(tfd);
    close(ofd);
    close(ifd);
    close(dfd);
    close(rfd);
    close(sfd);

    return 0;
}

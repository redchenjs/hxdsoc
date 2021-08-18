/*
 * hxd32.c
 *
 *  Created on: 2021-08-17 16:05
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

    printf("=> CPU_RST....\n");
}

void cpu_run(int sfd)
{
    uint8_t send_buff[] = {0x2b};

    write(sfd, send_buff, sizeof(send_buff));

    printf("=> CPU_RUN....\n");
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

        printf(">> DATA_WR: %d%%\r", i * 100 / size);
    }

    printf("=> DATA_WR: 100%%\n");
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

        printf("<< DATA_RD: %d%%\r", i * 100 / size);
    }

    printf("<= DATA_RD: 100%%\n");
}

int main(int argc, char *argv[])
{
    int sfd, ifd, dfd, ofd;
    struct stat st;
    struct termios conf;
    char *port = argv[1];
    char *iramfile = argv[2];
    char *dramfile = argv[3];
    char *outfile = argv[4];
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

    if ((ofd = open(outfile, O_CREAT | O_WRONLY | O_TRUNC, 0644)) < 0) {
        printf("failed to open output file: %s\n", outfile);

        return -1;
    }

    conf.c_iflag = 0;
    conf.c_oflag &= ~OPOST;
    conf.c_lflag &= ~(ISIG | ICANON);
    conf.c_cflag |= CLOCAL | CREAD | CS8;

    conf.c_cc[VMIN] = 1;
    conf.c_cc[VTIME] = 0;

    cfsetispeed(&conf, B921600);
    cfsetospeed(&conf, B921600);

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
    conf_wr(sfd, 0x00000000, size + 3);
    data_wr(sfd, ifd, size);

    // zero iram
    write(sfd, &data, 4);

    stat(dramfile, &st);
    size = st.st_size;

    // write dram
    if (size != 0) {
        conf_wr(sfd, 0x10000000, size - 1);
        data_wr(sfd, dfd, size);
    }

    // cpu run
    cpu_run(sfd);

    // wait cpu
    while (data != 0xef) {
        read(sfd, &data, 1);
    }

    stat(dramfile, &st);
    size = st.st_size;

    // read dram
    if (size != 0) {
        conf_wr(sfd, 0x10000000, size - 1);
        data_rd(sfd, ofd, size);
    }

    // cpu reset
    cpu_rst(sfd);

    close(ofd);
    close(dfd);
    close(ifd);
    close(sfd);

    return 0;
}

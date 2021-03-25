#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "execute.h"

#define IMEM_SIZE 4096
#define DMEM_SIZE 8192

int
main(int argc, char **argv)
{
  if (argc < 3) {
    fprintf(stderr, "argc: %d < 3\n", argc);
    return -1;
  }

  int imem_fd;
  imem_fd = open(argv[1], O_RDONLY);
  if (imem_fd < 0) {
    fprintf(stderr, "open: %s\n", strerror(errno));
    return -1;
  }

  int dmem_fd;
  dmem_fd = open(argv[2], O_RDONLY);
  if (dmem_fd < 0) {
    fprintf(stderr, "open: %s\n", strerror(errno));
    return -1;
  }

  char imem[IMEM_SIZE];
  char dmem[DMEM_SIZE];
  ssize_t len;

  len = read(imem_fd, imem, IMEM_SIZE);
  if (len < 0) {
    fprintf(stderr, "read: %s\n", strerror(errno));
    return -1;
  }
  close(imem_fd);

  len = read(dmem_fd, dmem, DMEM_SIZE);
  if (len < 0) {
    fprintf(stderr, "read: %s\n", strerror(errno));
    return -1;
  }
  close(dmem_fd);

  int int_reg[32];
  int last_pc = 0;
  int pc = 0;
  int ret;

  while (1) {
    ret = execute_step(&pc, int_reg, imem, dmem);
    if (ret < 0) {
      fprintf(stderr, "execute_step: %d\n", ret);
      return -1;
    }

    fprintf(stderr, "pc=%x x1=%08x x2=%08x x10=%08x x11=%08x x12=%08x x31=%08x\n",
            pc, int_reg[1], int_reg[2], int_reg[10], int_reg[11], int_reg[12], int_reg[31]);
    if (pc == last_pc) {
      fprintf(stderr, "pc == last_pc: %x\n", pc);
      break;
    }
    last_pc = pc;
  }

  return 0;
}

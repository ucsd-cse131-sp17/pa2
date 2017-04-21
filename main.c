#include <stdio.h>
#include <stdlib.h>

extern int our_code_starts_here() asm("our_code_starts_here");
extern int print(int val) asm("print");
extern void error(int val) asm('error');

void error(int error_code) {
  fprintf(stderr, "TODO: main.c error");
  if(error_code == 0)
    fprintf(stderr, "TODO: main.c error");
  else if(error_code == 1)
    fprintf(stderr, "TODO: main.c error");

  exit(123456);
}

int print(int val) {
  printf("Unknown value: %#010x\n", val);
  return val;
}

int main(int argc, char** argv) {
  int result = our_code_starts_here();
  print(result);
  return 0;
}

#include <stdio.h>
#include <string.h>

int main(int argc, char **argv)
{
  int r0 = 0, r2 = 1003;

  if (argc >= 2 && 0 == strcmp(argv[1], "part2")) {
    r2 += 10550400;
  }

  for(int r3 = 1; r3 <= r2; r3++) {
    for(int r5 = 1; r5 <= r2; r5++) {
      if (r3 * r5 == r2)
        r0 += r3;
    }
  }

  printf("%d\n", r0);
  return 0;
}

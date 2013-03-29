#include<stdio.h>
int main()
{
  void *vPtr;
  printf("You have a %d-bit machine\n", sizeof((void *)vPtr)*8);
  return 0;
}

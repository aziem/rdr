extern int printf (const char *__restrict __format, ...);

int main (){
  unsigned long lerpDerp = 40;
  
  printf("other libc: %lu\n", lerpDerp);

  return 0;
}

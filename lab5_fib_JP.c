#include <stdio.h>

int Fibonacci(int n) {
   if (n < 0) {
        return -1; 
    } else if (n == 0) {
        return 0;  
    } else if (n == 1) {
        return 1;  
    } else {
        return Fibonacci(n - 1) + Fibonacci(n - 2);
    }
}

int main() {
   int n;

   for (n = 0; n <= 16; n++) {
      printf("Fibonacci(%d) is %d\n", n, Fibonacci(n));
   }

   return 0;
}

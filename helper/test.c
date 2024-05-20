#include <stdlib.h>
#include <sys/ksys.h>
#include <string.h>

ksys_thread_t info;
static char p[100];

 /* reverse:  reverse string s in place */
 void reverse(char s[])
 {
     int i, j;
     char c;

     for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
         c = s[i];
         s[i] = s[j];
         s[j] = c;
     }
}  

 void itoa(int n, char s[])
 {
     int i, sign;

     if ((sign = n) < 0)  /* record sign */
         n = -n;          /* make n positive */
     i = 0;
     do {       /* generate digits in reverse order */
         s[i++] = n % 10 + '0';   /* get next digit */
     } while ((n /= 10) > 0);     /* delete it */
     if (sign < 0)
         s[i++] = '-';
     s[i] = '\0';
     reverse(s);
}

void dump()
{
    _ksys_thread_info(&info, KSYS_THIS_SLOT);
    itoa(info.memused, p);
    _ksys_debug_puts("DUMP:");
    _ksys_debug_puts(p);
    _ksys_debug_putc('\n');
}

int main()
{
    void* m[10000];

    dump();

    for (int i = 0; i < 10000; i++) {
        m[i] = malloc(1);
        if (m[i] == NULL) {
            _ksys_debug_puts("NULL!\n");
            return 1;
        }
    }

    dump();

    for (int i = 0; i < 10000; i++) {
        free(m[i]);
    }

    dump();

    return 0;
}

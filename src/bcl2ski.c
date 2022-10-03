#include <stdio.h>

char get01 () {
    char c;
    do {
        c = getchar();
    } while (!(c == '0' || c == '1' || c == EOF));
    return c;
}

int main (void) {
    char c;
    while ((c = get01()) != EOF) {
        if (c == '0') {
            c = get01();
            if (c == '0') {
                putchar('k');
            } else if (c == '1') {
                putchar('s');
            } else {
                fputs("Error: Unexpected EOF", stderr);
                return 1;
            } 
        } else if (c == '1') {
            putchar('`');
        }
    }
    return 0;
}

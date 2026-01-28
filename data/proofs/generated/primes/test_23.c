
#include <stdlib.h>
int main() {
    int *p = malloc(sizeof(int));
    *p = 23;
    int r = *p;
    free(p);
    return r;
}

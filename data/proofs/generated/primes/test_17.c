
#include <stdio.h>
struct Point {
    int x;
    int y;
};
int main() {
    struct Point p;
    p.x = 17;
    return p.x;
}

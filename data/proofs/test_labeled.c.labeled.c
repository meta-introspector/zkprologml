/* Source code labeled with perf trace complexity */

🟠 /* prime 3 */ int factorial(int n) {
⚫ /* prime 6 */   if (n <= 1) return 1;
⚫ /* prime 9 */   return n * factorial(n - 1);
⚫ /* prime 12 */ }
⚫ /* prime 15 */ 
⚫ /* prime 18 */ int main() {
⚫ /* prime 21 */   int result = factorial(10);
⚫ /* prime 24 */   return result;
}

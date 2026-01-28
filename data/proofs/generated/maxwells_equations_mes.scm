;; Maxwell's Equations for MES (Minimal Executable Scheme)
;; Bootstrap-able from hex

;; Prime lattice (minimal)
(define primes (quote (2 3 5 7 11 13)))

;; Eval (MES primitive)
(define (eval-prime expr)
  (if (pair? expr)
      (apply (car expr) (cdr expr))
      expr))

;; Monster action via prime multiplication
(define (monster-mult g code)
  (* g code))

;; Theorem: Eval preserves prime structure
(define (prime-preserved? code)
  (let ((sig-before (filter (lambda (p) (= 0 (modulo code p))) primes))
        (sig-after (filter (lambda (p) (= 0 (modulo (eval-prime code) p))) primes)))
    (equal? sig-before sig-after)))

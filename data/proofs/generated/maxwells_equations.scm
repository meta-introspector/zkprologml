;; Maxwell's Equations of Software in Scheme

;; Prime lattice
(define primes '(2 3 5 7 11 13 17 19 23 29))

;; Prime signature
(define (prime-signature n)
  (filter (lambda (p) (= 0 (modulo n p))) primes))

;; Lisp eval (meta-circular)
(define (lisp-eval expr env)
  (cond
    ((symbol? expr) (lookup expr env))
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       (apply (lisp-eval op env)
              (map (lambda (arg) (lisp-eval arg env)) args))))
    (else expr)))

;; Monster group action (simplified)
(define (monster-action g code)
  (* g code))

;; Theorem: eval commutes with monster action
(define (test-eval-commutes g code)
  (= (lisp-eval (monster-action g code) '())
     (monster-action g (lisp-eval code '()))))

;; Test
(display "Testing eval commutativity: ")
(display (test-eval-commutes 2 6))
(newline)

#lang racket

(require (for-syntax syntax/parse
                     racket/syntax))

(define-syntax (f stx)
  (syntax-parse stx
    [(_ 0 t c)
     #'(void)]
    [(_ n t c)
     #:when (positive? (syntax->datum #'n))
     #:with f-n (format-id stx "~a-~a" "f" (syntax->datum #'n))
     #:with n-1 (- (syntax->datum #'n) 1)
     #'(begin
         (define (f-n x)
           (for ([i (in-range x)])
             i))
         (for ([i (in-range c)])
           (f-n t))
         (f n-1 t c))]))

(define functions (string->number (or (getenv "FUNCTIONS") "1000")))
(define f-length  (string->number (or (getenv "FLENGTH")   "10")))
(define f-calls   (string->number (or (getenv "FCALLS")    "1250")))

(time
 (f 1000 10 1250))

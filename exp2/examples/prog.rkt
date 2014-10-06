#lang racket

(require (for-syntax syntax/parse
                     racket/syntax))

(define-syntax (f stx)
  (syntax-parse stx
    [(_ 0 t)
     #'(void)]
    [(_ n t)
     #:when (positive? (syntax->datum #'n))
     #:with f-n (format-id stx "~a-~a" "f" (syntax->datum #'n))
     #:with n-1 (- (syntax->datum #'n) 1)
     #'(begin
         (define (f-n x)
           (for ([i (in-range x)])
             i))
         (f-n t)
         (f n-1 t))]))

(time
 (f 1000 10))

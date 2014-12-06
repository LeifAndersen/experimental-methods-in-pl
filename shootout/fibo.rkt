#lang racket/base

(require racket/contract)

(define/contract (fib n)
  (-> natural-number/c natural-number/c)
  (cond ((< n 2) 1)
        (else (+ (fib (- n 2)) (fib (- n 1))))))

(define/contract (main args)
  (-> (vectorof string?) natural-number/c)
  (let ((n (if (= (vector-length args) 0)
               1
               (string->number (vector-ref args 0)))))
    (fib n)))

(time (begin (main (vector "42")) (void)))

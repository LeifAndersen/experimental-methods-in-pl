#lang racket/base

(require racket/contract)

(define/contract (main argv)
  (-> (vectorof string?) string?)
  (let* ([n (string->number (vector-ref argv 0))]
         [hash (make-hash)]
         [accum 0]
         [false (lambda () #f)])
    (define/contract (loop1 i)
      (-> natural-number/c void?)
      (unless (> i n)
        (hash-set! hash (number->string i 16) i)
        (loop1 (add1 i))))
    (loop1 1)
    (define/contract (loop2 i)
      (-> natural-number/c void?)
      (unless (zero? i)
        (when (hash-ref hash (number->string i) false)
          (set! accum (+ accum 1)))
        (loop2 (sub1 i))))
    (loop2 n)
    (format "~s\n" accum)))

(time (begin (main (vector "2000000")) (void)))

#lang racket/base

(require racket/contract)

(define (ack m n)
  (-> exact-nonnegative-integer? exact-nonnegative-integer? exact-nonnegative-integer?)
  (cond ((zero? m) (+ n 1))
        ((zero? n) (ack (- m 1) 1))
        (else      (ack (- m 1) (ack m (- n 1))))))

(define (main)
  (ack 3 12))
(time (begin (main) (void)))

#lang racket

(require "female.rkt"
         "male.rkt")

; (-> exact-non-negative-integer? exact-non-negative-integer?)
(define (fem n)
  (female mal n))

; (-> exact-non-negative-integer? exact-non-negative-integer?)
(define (mal n)
  (male fem n))

(time (mal 100))

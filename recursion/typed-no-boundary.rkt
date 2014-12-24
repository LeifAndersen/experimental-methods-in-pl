#lang typed/racket

(require "typed-male.rkt"
         "typed-female.rkt")

(: fem (Integer -> Integer))
(define (fem n)
  (female mal n))

(: mal (Integer -> Integer))
(define (mal n)
  (male fem n))

(time (mal 100))

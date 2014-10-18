#lang racket

(time
 (define total 0)
 (define (adder i)
   (set! total (+ total i)))
 (for ([i (in-range 1000000)])
   (adder i))
 (displayln total))

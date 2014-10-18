#lang racket

(time
 (define (adder val i)
   (+ val i))
 (displayln
  (for/fold ([total 0])
            ([i (in-range 1000000)])
    (adder total i))))

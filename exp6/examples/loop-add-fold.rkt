#lang racket

(time
 (displayln
  (for/fold ([total 0])
            ([i (in-range 1000000)])
    (+ total i))))

#lang racket

(time
 (define total 0)
 (for ([i (in-range 1000000)])
   (set! total (+ total i)))
 (displayln total))

#lang racket

(define glob #f)

(time
 (for ([i (in-range 100000000)])
   (set! glob (vector i i))))

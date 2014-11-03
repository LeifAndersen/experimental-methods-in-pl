#lang racket

(define glob #f)
(struct mystr (i j))

(time
 (for ([i (in-range 100000000)])
   (set! glob (mystr i i))))

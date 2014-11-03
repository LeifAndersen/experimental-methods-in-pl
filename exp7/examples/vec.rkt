#lang racket

(time
 (for ([i (in-range 1000000000)])
   (vector i i)))

#lang racket

(struct mystr (i j))

(time
 (for ([i (in-range 1000000000)])
   (mystr i i)))

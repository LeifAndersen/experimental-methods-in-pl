#lang racket

(time
 (define adder%
   (class object%
     (super-new)
     (define _total 0)
     (define/public (add i)
       (set! _total (+ _total i)))
     (define/public (total)
       _total)))

 (define total (new adder%))
 (for ([i (in-range 1000000)])
   (send total add i))
 (displayln (send total total)))

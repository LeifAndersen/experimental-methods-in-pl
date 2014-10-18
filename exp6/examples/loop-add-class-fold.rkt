#lang racket

(time
 (define adder%
   (class object%
     (super-new)
     (init-field total)
     (define/public (add i)
       (new this% [total (+ total i)]))))

 (displayln
  (get-field
   total
   (for/fold ([total (new adder% [total 0])])
             ([i (in-range 1000000)])
     (send total add i)))))

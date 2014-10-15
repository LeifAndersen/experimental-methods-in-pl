#lang typed/racket/base

(define SIZE 10000)

(define vec (make-vector SIZE))
(for ([i (in-range SIZE)])
  (vector-set! vec i (- SIZE i)))

(: bubble-sort ((Vectorof Integer) -> Void))
(define (bubble-sort vec)
  (when (for/fold: : Boolean ([swapped? : Boolean #f]) ([i : Integer (in-range (sub1 SIZE))])
          (let ([a (vector-ref vec i)]
                [b (vector-ref vec (+ 1 i))])
            (if (a . > . b)
                (begin
                  (vector-set! vec i b)
                  (vector-set! vec (+ 1 i) a)
                  #t)
                swapped?)))
    (bubble-sort vec)))

(time (bubble-sort vec))

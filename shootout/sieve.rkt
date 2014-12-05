#lang racket/base

(require racket/contract)

(define/contract (main args)
  (-> (vectorof string?) string?)
  (let ((n (if (= (vector-length args) 0)
               1
               (string->number (vector-ref args 0))))
        (count 0)
        (flags (make-vector 8192)))
    (define/contract (loop iter)
      (-> natural-number/c boolean?)
      (if (> iter 0)
          (begin
            (do ((i 0 (+ i 1))) ((>= i 8192)) (vector-set! flags i #t))
            (set! count 0)
            (do ((i 2 (+ 1 i)))
                ((>= i 8192))
              (if (vector-ref flags i)
                  (begin
                    (do ((k (+ i i) (+ k i)))
                        ((>= k 8192))
                      (vector-set! flags k #f))
                    (set! count (+ 1 count)))
                  #t))
            (loop (- iter 1)))
          #t))
    (loop n)
    (format "Count: ~a\n" count)))

(time (begin (main (vector "25000")) (void)))

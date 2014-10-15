;; This is a copy of "bubble.sch", but without the first line

(define SIZE 10000)

(define vec (make-vector SIZE))
(let loop ([i 0])
  (if (< i SIZE)
      (begin
        (vector-set! vec i (- SIZE i))
        (loop (+ 1 i)))
      #f))

(define (bubble-sort vec)
  (define SIZE-1 (- SIZE 1))
  (if (let loop ([swapped? #f] [i 0])
        (if (= i SIZE-1)
            swapped?
            (let ([a (vector-ref vec i)]
                  [b (vector-ref vec (+ 1 i))])
              (if (> a b)
                  (begin
                    (vector-set! vec i b)
                    (vector-set! vec (+ 1 i) a)
                    (loop #t (+ i 1)))
                  (loop swapped? (+ 1 i))))))
      (bubble-sort vec)
      #f))

(time (bubble-sort vec))

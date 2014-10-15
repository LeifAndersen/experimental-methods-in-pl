(import (rnrs) (larceny benchmarking))

(define-record-type (fish make-fish fish?)
  (fields (immutable weight)
          (immutable color)))

(define N 100000000)

(define (loop f)
  (time
   (let loop ([i N])
     (if (zero? i)
         'done
         (begin
           (fish-weight f)
           (loop (- i 1)))))))

'direct
(loop (make-fish 1 "blue"))

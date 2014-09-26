#lang typed/racket #:no-optimize

(require math/matrix)

(define (random-matrix)
  (build-matrix 200 200 (λ (i j) (random))))

(time (matrix* (random-matrix) (random-matrix)))

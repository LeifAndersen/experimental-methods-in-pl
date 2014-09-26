#lang typed/racket

(require math/matrix)

(define (random-matrix)
  (build-matrix 200 200 (λ (i j) (random))))

(time (matrix* (random-matrix) (random-matrix)))

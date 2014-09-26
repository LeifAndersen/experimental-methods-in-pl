#lang racket

(require math/matrix)

(define (random-matrix)
  (build-matrix 1000 1000 (λ (i j) (random))))

(time (matrix* (random-matrix) (random-matrix)))

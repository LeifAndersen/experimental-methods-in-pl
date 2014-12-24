#lang typed/racket

(provide female)

(: female (-> (Integer -> Integer) Integer Integer))
(define (female male n)
  (if (zero? n)
      0
      (n . - . (male (female male (n . - . 1))))))

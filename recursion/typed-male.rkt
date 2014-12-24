#lang typed/racket

(provide male)

(: male (-> (Integer -> Integer) Integer Integer))
(define (male female n)
  (if (zero? n)
      0
      (n . - . (female (male female (n . - . 1))))))

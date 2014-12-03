#lang racket

;; 145 is a curious number, as 1! + 4! + 5! = 1 + 24 + 120 = 145.
;; Find the sum of all numbers which are equal to the sum of the factorial of their digits.
;; Note: as 1! = 1 and 2! = 2 are not sums they are not included.

(define (nat? x)
  (or (positive? x)
      (zero? x)))
(define (gt-10? x)
  (x . > . 10))

(define/contract (fact-acc-aux n acc)
  (-> nat? nat? nat?)
  (if (< n 2) acc (fact-acc-aux (sub1 n) (* n acc))))
(define/contract (fact-acc n)
  (-> nat? nat?)
  (fact-acc-aux n 1))

(define/contract (fact-sum n)
  (-> nat? nat?)
  ;; sum the factorials of the digits of n
  (for/sum ([d (~a n)]) (fact-acc (- (char->integer d) 48))))

(define/contract (run limit)
  (-> gt-10? nat?)
  (for/sum ([i (in-range 10 limit)])
    (if (= i (fact-sum i)) i 0)))

(define (main) (run 9000000))
(time (begin (main) (void)))

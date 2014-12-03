#lang racket

; there are 4 fractions with 2 digits in numerator and denominator such that
; cancelling digits on the top and bottom gives a correct, simplified fraction.
; find their product, simplify it, return denominator

; this is a brute-force solution

;; Not a comprehension because we want to go slower
;; (define (two-digit-numbers-aux n)
;;   (if (= n 100)
;;       empty
;;       (cons n (two-digit-numbers-aux (add1 n)))))
;; (define (two-digit-numbers)
;;   (two-digit-numbers-aux 10))
(define two-digit-numbers
  (for/list ([i (in-range 10 100)]) i))
  
(define two-digit-pairs
  (for*/list ([i two-digit-numbers] [j two-digit-numbers])
    (cons i j)))

(define/contract (to-int c)
  (-> char? integer?)
  (- (char->integer c) 48))

(define/contract (number->list n)
  (-> exact-positive-integer? (listof integer?))
  (for/list ([c (number->string n)])
    (to-int c)))

(define/contract (str-member c str)
  (-> char? string? boolean?)
  (for/or ([c* str])
    (char=? c c*)))

(define/contract (shared-digits a b)
  (-> exact-positive-integer? exact-positive-integer? (listof exact-positive-integer?))
  (let ([a-str (number->string a)]
        [b-str (number->string b)])
    (filter (lambda (x) (not (= x 0)))
            (for*/list ([a-c a-str] #:when (str-member a-c b-str)) (to-int a-c)))))

(define/contract (remove-digit d a)
  (-> exact-positive-integer? exact-positive-integer? (listof exact-positive-integer?))
  (let* ([a-list (number->list a)]
         [fst-a  (first a-list)]
         [snd-a  (second a-list)])
    (append (if (and (not (= 0 snd-a))
                     (= d fst-a)) (list snd-a) empty)
            (if (and (not (= 0 fst-a))
                     (= d snd-a)
                     (not (= fst-a snd-a))) (list fst-a) empty))))

(define/contract (is-special? pair)
  (-> (cons/c exact-positive-integer? exact-positive-integer?) boolean?)
  (let* ([a (car pair)]
         [b (cdr pair)]
         [q (/ a b)])
    (and (< a b) ; fraction < 1
         (for*/or ([d  (shared-digits a b)]
                   [a* (remove-digit d a)]
                   [b* (remove-digit d b)])
           (equal? q (/ a* b*))))))

(define (lt-one? n)
  (and/c (number? n)
         (< 0 n)
         (> 1 n)))

(define/contract (special-fractions-aux pairs)
  (-> (listof (cons/c exact-positive-integer? exact-positive-integer?)) (listof lt-one?))
  (cond [(empty? pairs) empty]
        [(is-special? (first pairs)) (cons (/ (car (first pairs)) (cdr (first pairs)))
                                          (special-fractions-aux (rest pairs)))]
        [else (special-fractions-aux (rest pairs))]))

(define (special-fractions)
  (special-fractions-aux two-digit-pairs))

(define (main)
  (denominator (apply * (special-fractions))))

(time (begin (main) (void)))

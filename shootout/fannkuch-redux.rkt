#lang racket/base

(require racket/unsafe/ops
         racket/contract)

;; fannkuch benchmark for The Computer Language Shootout
;; Written by Dima Dorfman, 2004
;; Slightly improved by Sven Hartrumpf, 2005-2006
;; Ever-so-slightly tweaked for MzScheme by Brent Fulgham
;; PLT-ized for v4.0 by Matthew

(require racket/cmdline)

(define nat? natural-number/c)

(define/contract (fannkuch n)
  (-> nat? (cons/c nat? integer?))
  (let ([pi (list->vector 
             (for/list ([i (in-range n)]) i))]
        [tmp (make-vector n)]
        [count (make-vector n)])
    (define/contract (loop1 flips perms r checksum even-parity?)
      (-> nat? nat? nat? integer? boolean? (cons/c nat? integer?))
      (for ([i (in-range r)])
        (unsafe-vector-set! count i (unsafe-fx+ 1 i)))
      (define next-flips (count-flips pi tmp))
      (define flips2 (max next-flips flips))
      (define next-checksum (unsafe-fx+ checksum (if even-parity? next-flips (unsafe-fx- 0 next-flips))))
      (define/contract (loop2 r)
        (-> nat? (cons/c nat? integer?))
          (if (unsafe-fx= r n)
              (cons flips2 next-checksum)
              (let ((perm0 (unsafe-vector-ref pi 0)))
                (for ([i (in-range r)])
                  (unsafe-vector-set! pi i (unsafe-vector-ref pi (unsafe-fx+ 1 i))))
                (unsafe-vector-set! pi r perm0)
                (unsafe-vector-set! count r (unsafe-fx- (unsafe-vector-ref count r) 1))
                (cond
                  [(<= (unsafe-vector-ref count r) 0)
                   (loop2 (unsafe-fx+ 1 r))]
                  [else (loop1 flips2 
                              (unsafe-fx+ 1 perms)
                              r 
                              next-checksum
                              (not even-parity?))]))))
      (loop2 1))
    (loop1 0 0 n 0 #t)))

(define/contract (count-flips pi rho)
  (-> (vectorof nat?) (vectorof nat?) nat?)
  (vector-copy! rho 0 pi)
  (let loop ([i 0])
    (if (unsafe-fx= (unsafe-vector-ref rho 0) 0)
        i
        (begin
          (vector-reverse-slice! rho 0 (unsafe-fx+ 1 (unsafe-vector-ref rho 0)))
          (loop (unsafe-fx+ 1 i))))))

(define/contract (vector-reverse-slice! v i j)
  (-> (vectorof nat?) nat? nat? void?)
  (let loop ([i i]
             [j (unsafe-fx- j 1)])
    (when (unsafe-fx> j i)
      (vector-swap! v i j)
      (loop (unsafe-fx+ 1 i) (unsafe-fx- j 1)))))

(define-syntax-rule (vector-swap! v i j)
  (let ((t (unsafe-vector-ref v i)))
    (unsafe-vector-set! v i (unsafe-vector-ref v j))
    (unsafe-vector-set! v j t)))

(define/contract (main n)
  (-> nat? string?)
              (define r
                (fannkuch n))
              (format "~a\nPfannkuchen(~a) = ~a\n" 
                      (cdr r)
                      n
                      (car r)))
(time (begin (main 10) (void)))

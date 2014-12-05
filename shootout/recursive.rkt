;; ---------------------------------------------------------------------
;; The Computer Language Benchmarks Game
;; http://shootout.alioth.debian.org/
;;
;; Code based on / inspired by existing, relevant Shootout submissions
;;
;; Derived from the Chicken variant, which was
;; Contributed by Anthony Borla
;; ---------------------------------------------------------------------

#lang racket/base
(require racket/cmdline
         racket/contract
         racket/flonum)

(define nat? natural-number/c)

;; -------------------------------

(define/contract (ack m n)
  (-> nat? nat? nat?)
  (cond ((zero? m) (+ n 1))
        ((zero? n) (ack (- m 1) 1))
        (else (ack (- m 1) (ack m (- n 1))))))

;; --------------

(define/contract (fib n)
  (-> nat? nat?)
  (cond ((< n 2) 1)
        (else (+ (fib (- n 2)) (fib (- n 1))))))

(define/contract (fibflt n)
  (-> number? number?)
  (cond ((fl< n 2.0) 1.0)
        (else (fl+ (fibflt (fl- n 2.0)) (fibflt (fl- n 1.0))))))

;; --------------

(define/contract (tak x y z)
  (-> nat? nat? nat? nat?)
  (cond ((not (< y x)) z)
        (else (tak (tak (- x 1) y z) (tak (- y 1) z x) (tak (- z 1) x y)))))

(define/contract (takflt x y z)
  (-> number? number? number? number?)
  (cond ((not (fl< y x)) z)
        (else (takflt (takflt (fl- x 1.0) y z) (takflt (fl- y 1.0) z x) (takflt (fl- z 1.0) x y)))))

;; -------------------------------

(define/contract (main n)
  (-> natural-number/c string?)

  (format "Ack(3,~A): ~A\n" n (ack 3 n))
  (format "Fib(~a): ~a\n" 
          (real->decimal-string (+ 27.0 n) 1)
          (real->decimal-string (fibflt (+ 27.0 n)) 1))
  
  (set! n (- n 1))
  (format "Tak(~A,~A,~A): ~A\n" (* n 3) (* n 2) n (tak (* n 3) (* n 2) n))
  
  (format "Fib(3): ~A\n" (fib 3))
  (format "Tak(3.0,2.0,1.0): ~a\n" (real->decimal-string (takflt 3.0 2.0 1.0) 1)))

;; -------------------------------

(time (begin (main 12) (void)))

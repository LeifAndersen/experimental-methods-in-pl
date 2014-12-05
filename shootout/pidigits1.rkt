#lang racket/base

; The Computer Language Shootout
; http://shootout.alioth.debian.org/
; Sven Hartrumpf 2005-04-12
; Implements 'Spigot' algorithm origionally due to Stanly Rabinowitz.
; This program is based on an implementation for SCM by Aubrey Jaffer and
; Jerry D. Hedden.

(require racket/contract)

(define/contract (pi n d)
  (-> natural-number/c natural-number/c void?)
  (let* ((r (inexact->exact (floor (exp (* d (log 10)))))) ; 10^d
         (p (+ (quotient n d) 1))
         (m (quotient (* p d 3322) 1000))
         (a (make-vector (+ m 1) 2)))
    (vector-set! a m 4)
    (define/contract (j-loop b digits)
      (-> natural-number/c natural-number/c void?)
      (if (= digits n)
          ;; Add whitespace for ungenerated digits
          (let ([left (modulo digits 10)])
            (unless (zero? left)
              (format "~a\t:~a\n" (make-string (- 10 left) #\space) n)))
          ;; Compute more digits
          (loop m 0 b digits)))
     (define/contract (loop k q b digits)
       (-> natural-number/c natural-number/c natural-number/c natural-number/c void?)
            (if (zero? k)
                (let* ((s (let ([s (number->string (+ b (quotient q r)))])
                            (if (zero? digits)
                                s
                                (string-append (make-string (- d (string-length s)) #\0) s)))))
                  (j-loop (remainder q r)
                          (print-digits s 0 (string-length s) digits n)))
                (let ([q (+ q (* (vector-ref a k) r))])
                  (let ((t (+ (* k 2) 1)))
                    (let-values ([(qt rr) (quotient/remainder q t)])
                      (vector-set! a k rr)
                      (loop (sub1 k) (* k qt) b digits))))))
    (j-loop 2 0)
                      ))

(define/contract (print-digits s start end digits n)
  (-> string? natural-number/c natural-number/c natural-number/c natural-number/c natural-number/c)
  (let* ([len (- end start)]
         [cnt (min len (- n digits) (- 10 (modulo digits 10)) len)])
    (if (zero? cnt)
        digits
        (begin
          ; (write-string s start (+ start cnt))
          (let ([digits (+ digits cnt)])
            (when (zero? (modulo digits 10))
              (format "\t:~a\n" digits))
            (print-digits s (+ start cnt) end digits n))))))

(define/contract (main args)
  (-> (vectorof string?) void?)
  (let ((n (if (= (vector-length args) 0)
               1
               (string->number (vector-ref args 0)))))
    (pi n 10)))

(time (begin (main (vector "4000")) (void)))

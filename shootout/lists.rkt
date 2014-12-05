#lang racket/base

(require racket/contract)

(require compatibility/mlist)
(define SIZE 10000)
(define nat? natural-number/c)

(define/contract (sequence start stop)
  (-> nat? nat? (mlistof nat?))
  (if (> start stop)
      '()
      (mcons start (sequence (+ start 1) stop))))

(define/contract (head-to-tail! headlist taillist)
  (-> (mlistof natural-number/c) (mlistof natural-number/c) (values (mlistof natural-number/c) (mlistof natural-number/c)))
  (when (null? taillist) (begin
                           (set! taillist (mlist (mcar headlist)))
                           (set! headlist (mcdr headlist))))
  (define/contract (htt-helper dest)
    (-> (mlistof natural-number/c) void?)
                         (when (not (null? headlist))
                           (let ((headlink headlist))
                             (set-mcdr! dest headlink)
                             (set! headlist (mcdr headlist))
                             (htt-helper headlink))))
    (htt-helper taillist)
    (values headlist taillist))

(define/contract (test-lists)
  (-> natural-number/c)
  (let* ([L1 (sequence 1 SIZE)]
         [L2 (mappend L1 '())]
         [L3 '()])
    (set!-values (L2 L3) (head-to-tail! L2 L3))
    (set!-values (L3 L2) (head-to-tail! (mreverse! L3) L2))
    (set! L1 (mreverse! L1))
    (cond ((not (= SIZE (mcar L1))) 0)
          ((not (equal? L1 L2))    0)
          (else           (mlength L1)))))

(define/contract (main args)
  (-> (vectorof string?) string?)
  (let ((result 0))
    (define/contract (loop counter)
      (-> natural-number/c void?)
      (when (> counter 0)
        (set! result (test-lists))
        (loop (- counter 1))))
    (loop (if (= 0 (vector-length args)) 1 (string->number (vector-ref args 0))))
    (format "~s\n" result)))

(time (begin (main (vector "2000")) (void)))

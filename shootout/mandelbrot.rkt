#lang racket/base

;; The Computer Language Benchmarks Game
;; http://shootout.alioth.debian.org/
(require racket/contract)
(require racket/require racket/require-syntax (for-syntax racket/base))
(define-require-syntax overriding-in
  (syntax-rules () [(_ R1 R2) (combine-in R2 (subtract-in R1 R2))]))
(require (overriding-in
          racket/flonum
          (filtered-in (lambda (name) (regexp-replace #rx"unsafe-" name ""))
                       racket/unsafe/ops))
         racket/cmdline)

(define O (current-output-port))

(define LIMIT-SQR 4.0)
(define ITERATIONS 50)

(define nat? natural-number/c)

(define/contract (mandelbrot Cr Ci)
  (-> number? number? number?)
  (define/contract (loop i Zr Zi)
    (-> nat? number? number? number?)
    (cond [(fl> (fl+ (fl* Zr Zr) (fl* Zi Zi)) LIMIT-SQR) 0]
          [(fx= i ITERATIONS) 1]
          [else (let ([Zr (fl+ (fl- (fl* Zr Zr) (fl* Zi Zi)) Cr)]
                      [Zi (fl+ (fl* 2.0 (fl* Zr Zi)) Ci)])
                  (loop (fx+ i 1) Zr Zi))]))
  (loop 0 0.0 0.0)
                  )

(define/contract (loop-y y N 2/N Crs)
  (-> nat? nat? number? flvector? void?)
  (let ([Ci (fl- (fl* 2/N (fx->fl y)) 1.0)])
    (define/contract (loop-x x bitnum byteacc)
      (-> nat? nat? nat? void?)
      (if (fx< x N)
        (let* ([Cr (flvector-ref Crs x)]
               [bitnum (fx+ bitnum 1)]
               [byteacc (fx+ (fxlshift byteacc 1) (mandelbrot Cr Ci))])
          (cond [(fx= bitnum 8)
                 ;(write-byte byteacc O)
                 (loop-x (fx+ x 1) 0 0)]
                [else (loop-x (fx+ x 1) bitnum byteacc)]))
        (begin (when (fx> bitnum 0)
                 (void) ;;(write-byte (fxlshift byteacc (fx- 8 (fxand N #x7))) O)
                 )
               (when (fx> y 1) (loop-y (fx- y 1) N 2/N Crs)))))
    (loop-x 0 0 0)
               ))

(define/contract (main N)
    (-> nat? void?)
    (define N.0 (fx->fl N))
    (define 2/N (fl/ 2.0 N.0))
    (define Crs
      (let ([v (make-flvector N)])
        (for ([x (in-range N)])
          (flvector-set! v x (fl- (fl/ (fx->fl (fx* 2 x)) N.0) 1.5)))
        v))
    (loop-y N N 2/N Crs))

(time (begin (main 3000) (void)))

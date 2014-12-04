#lang racket/base

;; The Computer Language Benchmarks Game
;; http://shootout.alioth.debian.org/
;;
;; fasta - benchmark
;;
;; Very loosely based on the Chicken variant by Anthony Borla, some
;; optimizations taken from the GCC version by Petr Prokhorenkov, and
;; additional heavy optimizations by Eli Barzilay (not really related to
;; the above two now).
;;
;; If you use some of these optimizations in other solutions, please
;; include a proper attribution to this Racket code.

(require racket/contract)
(define nat? natural-number/c)

(define +alu+
  (bytes-append #"GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
                #"GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
                #"CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
                #"ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
                #"GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
                #"AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
                #"AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"))

(define IUB
  '([#\a 0.27] [#\c 0.12] [#\g 0.12] [#\t 0.27] [#\B 0.02]
    [#\D 0.02] [#\H 0.02] [#\K 0.02] [#\M 0.02] [#\N 0.02]
    [#\R 0.02] [#\S 0.02] [#\V 0.02] [#\W 0.02] [#\Y 0.02]))

(define HOMOSAPIEN
  '([#\a 0.3029549426680] [#\c 0.1979883004921]
    [#\g 0.1975473066391] [#\t 0.3015094502008]))

(define line-length 60)

;; ----------------------------------------

(require racket/cmdline racket/require (for-syntax racket/base)
         (filtered-in (lambda (name) (regexp-replace #rx"unsafe-" name ""))
                       racket/unsafe/ops))

;; ----------------------------------------

(define/contract (repeat-fasta header N sequence)
  (-> string? nat? bytes? void?)
  (define out (current-output-port))
  (define len (bytes-length sequence))
  (define buf (make-bytes (+ len line-length)))
  (bytes-copy! buf 0 sequence)
  (bytes-copy! buf len sequence 0 line-length)
  ; (display header out)
  (define/contract (loop n start)
    (-> nat? nat? void?)
    (when (fx> n 0)
      (let ([end (fx+ start (fxmin n line-length))])
        ;(write-bytes buf out start end)
        ;(newline)
        (loop (fx- n line-length) (if (fx> end len) (fx- end len) end)))))
  (loop N 0))

;; ----------------------------------------

(define IA 3877)
(define IC 29573)
(define IM 139968)
(define IM.0 (fx->fl IM))

(define-syntax-rule (define/IM (name id) E)
  (begin (define V
           (let ([v (make-vector IM)])
             (for ([id (in-range IM)]) (vector-set! v id E))
             v))
         (define-syntax-rule (name id) (vector-ref V id))))

(define/IM (random-next cur) (fxmodulo (fx+ IC (fx* cur IA)) IM))

(define/contract (make-lookup-table frequency-table)
  (-> (listof (list/c char? number?)) bytes?)
  (define v (make-bytes IM))
  (define/contract (loop t c c.)
    (-> (listof (list/c char? number?)) nat? number? void?)
    (unless (null? t)
      (let* ([c1. (fl+ c. (fl* IM.0 (cadar t)))]
             [c1 (inexact->exact (flceiling c1.))]
             [b (char->integer (caar t))])
        (for ([i (in-range c c1)]) (bytes-set! v i b))
        (loop (cdr t) c1 c1.))))
  (loop frequency-table 0 0.0)
  v)

(define/contract (random-fasta header N table R)
  (-> string? nat? (listof (list/c char? number?)) nat? nat?)
  (define out (current-output-port))
  (define lookup-byte (make-lookup-table table))
  (define/contract (n-randoms to R)
    (-> nat? nat? nat?)
    (define/contract (loop n R)
      (-> nat? nat? nat?)
      (if (fx< n to)
        (let ([R (random-next R)])
          (bytes-set! buf n (bytes-ref lookup-byte R))
          (loop (fx+ n 1) R))
        R))
    (loop 0 R)
        )
        ; (begin (write-bytes buf out 0 (fx+ to 1)) R))))
  (define/contract (make-line! buf start R)
    (-> bytes? integer? integer? nat?)
    (let ([end (fx+ start line-length)])
      (bytes-set! buf end LF)
      (define/contract (loop n R)
        (-> nat? nat? nat?)
        (if (fx< n end)
          (let ([R (random-next R)])
            (bytes-set! buf n (bytes-ref lookup-byte R))
            (loop (fx+ n 1) R))
          R))
      (loop start R)
          ))
  (define LF (char->integer #\newline))
  (define buf (make-bytes (fx+ line-length 1)))
  (define-values (full-lines last) (quotient/remainder N line-length))
  (define C
    (let* ([len+1 (fx+ line-length 1)]
           [buflen (fx* len+1 IM)]
           [buf (make-bytes buflen)])
      (define/contract (loop R i)
        (-> nat? nat? bytes?)
        (if (fx< i buflen)
          (loop (make-line! buf i R) (fx+ i len+1))
          buf))
      (loop R 0)
          ))
  (bytes-set! buf line-length LF)
  ; (display header out)
  (define/contract (loop1 i R)
    (-> nat? nat? nat?)
      (define/contract (loop2 i R)
        (-> nat? nat? nat?)
        (cond [(fx> i 0) (loop2 (fx- i 1) (n-randoms line-length R))]
              [(fx> last 0) (bytes-set! buf last LF) (n-randoms last R)]
              [else R]))
    (if (fx> i IM)
      (begin ; (display C out)
             (loop1 (fx- i IM) R))
      (loop2 i R)))
  (loop1 full-lines R)
                )

;; ----------------------------------------

(define/contract (main n)
  (-> nat? void?)
  (repeat-fasta ">ONE Homo sapiens alu\n" (* n 2) +alu+)
  (random-fasta ">THREE Homo sapiens frequency\n" (* n 5) HOMOSAPIEN
                (random-fasta ">TWO IUB ambiguity codes\n" (* n 3) IUB 42))
  (void))

(time (begin (main 100000000) (void)))

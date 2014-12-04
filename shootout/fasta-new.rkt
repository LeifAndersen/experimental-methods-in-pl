#lang racket/base

;;; The Computer Language Benchmarks Game
;;; http://shootout.alioth.debian.org/

;;; Derived from C version by Joern Inge Vestgaarden 
;;;                 and Jorge Peixoto de Morais Neto
;;; Contributed by Sam Tobin-Hochstadt

(require racket/cmdline racket/require (for-syntax racket/base) (only-in racket/flonum for/flvector)
         racket/contract
         (filtered-in (λ (name) (regexp-replace #rx"unsafe-" name ""))
                       racket/unsafe/ops))

(define +alu+
  (bytes-append #"GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
                #"GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
                #"CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
                #"ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
                #"GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
                #"AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
                #"AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"))

(define/contract (build-table t)
  (-> (listof (cons/c char? number?)) (cons/c bytes? any/c)) ; flvector? unbound
  (cons (apply bytes (map (compose char->integer car) t))
        (for/flvector ([i t]) (cdr i))))

(define IUB
  (build-table
   '([#\a . 0.27] [#\c . 0.12] [#\g . 0.12] [#\t . 0.27] [#\B . 0.02]
     [#\D . 0.02] [#\H . 0.02] [#\K . 0.02] [#\M . 0.02] [#\N . 0.02]
     [#\R . 0.02] [#\S . 0.02] [#\V . 0.02] [#\W . 0.02] [#\Y . 0.02])))

(define HOMOSAPIEN
  (build-table '([#\a . 0.3029549426680] [#\c . 0.1979883004921]
                 [#\g . 0.1975473066391] [#\t . 0.3015094502008])))

;; -------------

(define line-length 60)

(define IA 3877)
(define IC 29573)
(define IM 139968)

;; -------------------------------

(define LAST 42)

;; -------------------------------

(define/contract (make-cumulative-table frequency-table)
  (-> (cons/c bytes? any/c) void?)
  (define bs (car frequency-table))
  (define ps (cdr frequency-table))
  (define len (bytes-length bs))
  (define/contract (loop i cum)
    (-> natural-number/c number? void?)
    (when (fx< i len)
      (define this (flvector-ref ps i))
      (define new (fl+ this cum))
      (flvector-set! ps i new)
      (loop (fx+ 1 i) new)))
  (loop 0 0.0)
      )

;; -------------

(define/contract (random-next max)
  (-> number? number?)
  (set! LAST (fxmodulo (fx+ IC (fx* LAST IA)) IM))
  (fl/ (fl* max (fx->fl LAST)) (fx->fl IM)))

;; -------------

(define/contract (repeat-fasta s count)
  (-> bytes? natural-number/c void?)
  (define out (current-output-port))  
  (define len (bytes-length s))
  (define s2 (make-bytes (fx+ len line-length)))  
  (bytes-copy! s2 0 s 0 len)
  (bytes-copy! s2 len s 0 line-length)
  (define/contract (loop count pos)
    (-> natural-number/c natural-number/c void?)
    (define line (fxmin line-length count))
    ;(write-bytes s2 out pos (fx+ pos line))
    ;(newline out)    
    (define count* (fx- count line))
    (when (fx> count* 0)
      (define pos* (fx+ pos line))      
      (loop count* (if (fx>= pos* len) (fx- pos* len) pos*))))
  (loop count 0)
      )


;; -------------

(define-syntax-rule (random-fasta genelist cnt)
  (let ()
    (define out (current-output-port))
    (define ps (cdr genelist))
    (define cs (car genelist))
    (define/contract (loop count)
      (-> natural-number/c void?)
      (define line (fxmin line-length count)) 
      (define buf (make-bytes (fx+ 1 line-length)))
      (define/contract (inner pos)
        (-> natural-number/c void?)
        (define r (random-next 1.0))
        (define i (let wh ([i 0]) (if (fl< (flvector-ref ps i) r) (wh (fx+ i 1)) i)))
        (bytes-set! buf pos (bytes-ref cs i))
        (define pos+ (fx+ pos 1))
        (when (fx< pos+ line)
          (inner pos+)))
      (inner 0)
      (bytes-set! buf line (char->integer #\newline))
      ;(write-bytes buf out 0 (fx+ line 1))
      (define count- (fx- count line))
      (when (fx> count- 0)
        (loop count-)))
    (loop cnt)
        ))

;; -------------------------------
  
(define (main n)
    (make-cumulative-table IUB)
    (make-cumulative-table HOMOSAPIEN)

    ;(display ">ONE Homo sapiens alu\n")
    (repeat-fasta +alu+ (* n 2))
    ;(display ">TWO IUB ambiguity codes\n")
    (random-fasta IUB (* n 3))
    ;(display ">THREE Homo sapiens frequency\n")
    (random-fasta HOMOSAPIEN (* n 5)))

(time (begin (main 100000000) (void)))

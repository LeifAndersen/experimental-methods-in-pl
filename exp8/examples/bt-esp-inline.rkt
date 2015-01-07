#lang racket/base

;;; The Computer Language Benchmarks Game
;;; http://shootout.alioth.debian.org/
;;; Derived from the Chicken variant by Sven Hartrumpf

(require racket/cmdline racket/require (for-syntax racket/base)
         (filtered-in (lambda (name) (regexp-replace #rx"unsafe-" name ""))
                      racket/unsafe/ops)
         syntax/quote syntax/srcloc
         racket/pretty racket/match
         (for-syntax syntax/parse)
         unstable/logging)

(begin-for-syntax
  (define (syntax->srcloc x)
    (vector (syntax-source x)
            (syntax-line x)
            (syntax-column x)
            (syntax-position x)
            (syntax-span x))))

(struct *leaf (val))
(struct *node *leaf (left right))

;(define-syntax leaf  (make-rename-transformer #'*leaf))
(define-syntax leaf? (make-rename-transformer #'*leaf?))
;(define-syntax node  (make-rename-transformer #'*node))
(define-syntax node? (make-rename-transformer #'*node?))
(define-syntax (leaf stx)
  (syntax-parse stx
    [(_ val)
     (quasisyntax/loc stx
;(define-syntax-rule (leaf val)
       (let ()
         (define start (current-process-milliseconds (current-thread)))
         (define l (*leaf val))
         (define end (current-process-milliseconds (current-thread)))
         (log-message (current-logger) 'info 'struct-profile ""
                      (vector #,(syntax->srcloc stx)
                              start
                              end))
         l)
     ;)
     )]))
(define-syntax (node stx)
  (syntax-parse stx
    [(_ val left right)
     (quasisyntax/loc stx
;(define-syntax-rule (node val left right)
       (let ()
         (define start (current-process-milliseconds (current-thread)))
         (define n (*leaf val))
         (define end (current-process-milliseconds (current-thread)))
         (log-message (current-logger) 'info 'struct-profile ""
                      (vector #,(syntax->srcloc stx)
                              start
                              end))
         n)
     ;)
     )]))
(define-syntax-rule (leaf-val l)   (struct-ref l 0))
(define-syntax-rule (node-left n)  (struct-ref n 1))
(define-syntax-rule (node-right n) (struct-ref n 2))

(define (make item d)
  (if (fx= d 0)
    (leaf item)
    (let ([item2 (fx* item 2)] [d2 (fx- d 1)])
      (node item (make (fx- item2 1) d2) (make item2 d2)))))

(define (check t)
  (let loop ([t t] [acc 0])
    (let ([acc (fx+ (leaf-val t) acc)])
      (if (node? t)
        (loop (node-left t)
              (fx- acc (loop (node-right t) 0)))
        acc))))

(define min-depth 4)

(define (main n)
  (let ([max-depth (max (+ min-depth 2) n)])
    (let ([stretch-depth (+ max-depth 1)])
      (printf "stretch tree of depth ~a\t check: ~a\n"
              stretch-depth
              (check (make 0 stretch-depth))))
    (let ([long-lived-tree (make 0 max-depth)])
      (for ([d (in-range 4 (+ max-depth 1) 2)])
        (let ([iterations (expt 2 (+ (- max-depth d) min-depth))])
          (printf "~a\t trees of depth ~a\t check: ~a\n"
                  (* 2 iterations)
                  d
                  (for/fold ([c 0]) ([i (in-range iterations)])
                    (fx+ c (fx+ (check (make i d))
                                (check (make (fx- 0 i) d))))))))
      (printf "long lived tree of depth ~a\t check: ~a\n"
              max-depth
              (check long-lived-tree)))))


;; For profiling
(define (extract-struct-feature times)
  (for/fold ([acc (hash 'total 0)])
            ([i times])
    (match i
      [(vector src t-start t-end)
       (define t-delta (- t-end t-start))
       (hash-set* acc
                  src (+ (hash-ref acc src 0) t-delta)
                  'total (+ (hash-ref acc 'total) t-delta))]
      [else (error (format "Expected feature, got: ~a" times))])))

#;
(define (extract-struct-feature times)
  (define (esf* times acc)
    (match times
      [(cons (vector stx t-start t-end) rest)
       (define t-delta (- t-end t-start))
       (esf* rest
             (hash-update acc stx (λ (x) (+ x t-delta)) t-delta))]
      [null acc]
      [else (error "Expected list, got ~a" times)]))
  (esf* times (hasheq 'total 0)))


(define (print-struct-feature ftimes)
  (printf "Struct Allocation: ~a~n" (hash-ref ftimes 'total))
  (for ([(k v) ftimes]
        #:unless (equal? k 'total))
    (printf "    ~a : ~a~n" k v)))

(module+ main
  (time
   ;(define times* '())
   (define times 0)

   (with-intercepted-logging
    (λ (i)
      (define s (vector-ref i 2))
      (set! times (+ times (- (vector-ref s 1)
                              (vector-ref s 2)))))
    (λ () (command-line #:args (n) (main (string->number n))))
    'info 'struct-profile)

   ;(define total-time (current-process-milliseconds (current-thread)))
   ;(displayln "Analyzing...")
   ;(define times (reverse times*))
   ;(define ftimes (extract-struct-feature times))
   ;(printf "Total time: ~a~n~n"total-time)
   #;(print-struct-feature ftimes)))

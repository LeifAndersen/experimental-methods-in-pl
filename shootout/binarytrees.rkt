#lang racket/base

;;; The Computer Language Benchmarks Game
;;; http://shootout.alioth.debian.org/
;;; Derived from the Chicken variant by Sven Hartrumpf

(require racket/cmdline
         racket/require
         racket/contract
         (for-syntax racket/base)
         (filtered-in (lambda (name) (regexp-replace #rx"unsafe-" name ""))
                      racket/unsafe/ops))

(struct *leaf (val))
(struct *node *leaf (left right))

(define-syntax leaf  (make-rename-transformer #'*leaf))
(define-syntax leaf? (make-rename-transformer #'*leaf?))
(define-syntax node  (make-rename-transformer #'*node))
(define-syntax node? (make-rename-transformer #'*node?))
(define-syntax-rule (leaf-val l)   (struct-ref l 0))
(define-syntax-rule (node-left n)  (struct-ref n 1))
(define-syntax-rule (node-right n) (struct-ref n 2))

(define (make item d)
  (-> any/c exact-nonnegative-integer? (or/c *node? *leaf?))
  (if (fx= d 0)
    (leaf item)
    (let ([item2 (fx* item 2)] [d2 (fx- d 1)])
      (node item (make (fx- item2 1) d2) (make item2 d2)))))

(define/contract (check t)
  (-> (or/c *node? *leaf?) integer?)
  (let loop ([t t] [acc 0])
    (let ([acc (fx+ (leaf-val t) acc)])
      (if (node? t)
        (loop (node-left t)
              (fx- acc (loop (node-right t) 0)))
        acc))))

(define min-depth 4)

(define/contract (main n)
  (-> exact-nonnegative-integer? string?)
  (let ([max-depth (max (+ min-depth 2) n)])
    (let ([stretch-depth (+ max-depth 1)])
      (format "stretch tree of depth ~a\t check: ~a\n"
              stretch-depth
              (check (make 0 stretch-depth))))
    (let ([long-lived-tree (make 0 max-depth)])
      (for ([d (in-range 4 (+ max-depth 1) 2)])
        (let ([iterations (expt 2 (+ (- max-depth d) min-depth))])
          (format "~a\t trees of depth ~a\t check: ~a\n"
                  (* 2 iterations)
                  d
                  (for/fold ([c 0]) ([i (in-range iterations)])
                    (fx+ c (fx+ (check (make i d))
                                (check (make (fx- 0 i) d))))))))
      (format "long lived tree of depth ~a\t check: ~a\n"
              max-depth
              (check long-lived-tree)))))

(time (begin (main 17) (void)))

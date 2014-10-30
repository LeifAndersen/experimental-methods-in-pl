#lang racket/base
(require (for-syntax racket/base))

(provide run-bubble)

(define-syntax-rule (run-bubble the-mode chaperone?)
  (...
   (begin
     ;; Adjust the last id in the following form to select the mode,
     ;; picking one of the following:
     ;;  plain unsafe unsafe*
     (define-syntax-rule (define-begin-current-mode)
       (define-begin-mode the-mode))

     ;; Adjust to enable or disable a chaperone for the argument:
     ;(define chaperone? #f)

     (define-syntax (define-begin-mode stx)
       (syntax-case stx ()
         [(_ mode)
          (with-syntax ([mode (datum->syntax #'here (syntax-e #'mode))]
                        [begin-mode (syntax-local-introduce #'begin-mode)])
            #'(...
               (define-syntax begin-mode
                 (syntax-rules (plain unsafe unsafe* unsafe/unsafe*)
                   [(_ mode e ...) (begin e ...)]
                   [(_ unsafe/unsafe* e ...)
                    (begin (begin-mode unsafe e ...)
                           (begin-mode unsafe* e ...))]
                   [(_ other e ...) (begin)]))))]))

     (define-begin-current-mode)

     ;; ----------------------------------------

     (begin-mode
      unsafe/unsafe*
      (require 
       (rename-in racket/unsafe/ops
                  [unsafe-fx> >]
                  [unsafe-fx+ +])))

     (begin-mode
      unsafe
      (require 
       (rename-in racket/unsafe/ops
                  [unsafe-vector-ref vector-ref]
                  [unsafe-vector-set! vector-set!])))

     (begin-mode
      unsafe*
      (require 
       (rename-in racket/unsafe/ops
                  [unsafe-vector*-ref vector-ref]
                  [unsafe-vector*-set! vector-set!])))


     (define SIZE 10000)

     (define vec (make-vector SIZE))
     (for ([i (in-range SIZE)])
       (vector-set! vec i (- SIZE i)))

     (define (bubble-sort vec)
       (when (for/fold ([swapped? #f]) ([i (in-range (sub1 SIZE))])
               (let ([a (vector-ref vec i)]
                     [b (vector-ref vec (+ 1 i))])
                 (if (a . > . b)
                     (begin
                       (vector-set! vec i b)
                       (vector-set! vec (+ 1 i) a)
                       #t)
                     swapped?)))
         (bubble-sort vec)))

     (time (bubble-sort
            (if chaperone?
                (chaperone-vector vec 
                                  (lambda (vec i val) val)
                                  (lambda (vec i val) val))
                vec))))))

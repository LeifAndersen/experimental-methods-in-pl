#lang racket
(provide (all-defined-out))
    
(define N 4)

(define (extract-number pattern in #:multiply [multiply 1])
  (define m (regexp-match pattern in))
  (unless m (error 'extract-number "match failed: ~e" pattern))
  (* multiply
     (string->number
      (bytes->string/utf-8 
       (cadr m)))))

(define orig-out (current-output-port))

(define (system/noisy s)
  (fprintf orig-out "~a\n" s)
  (system s))

(define (system/err-as-out s)
  (fprintf orig-out "~a\n" s)
  (define l (process/ports (current-output-port) (current-input-port) 'stdout s))
  ((list-ref l 4) 'wait)
  (eq? ((list-ref l 4) 'status) 'done-ok))

;; Runs the benchmark N+1 times, returns a hash table
;; mapping keys to lists of run results
(define (multi-run proc)
  ;; N runs:
  (define runs (for/list ([i N]) (proc)))
  (for/hash ([k (in-hash-keys (car runs))])
    (values k (for/list ([run runs]) (hash-ref run k)))))

(define merge
  (case-lambda
   [() (hash)]
   [(a) a]
   [(a b) (for/fold ([ht a]) ([(k v) (in-hash b)])
            (hash-set ht k v))]
   [(a b . rest)
    (apply merge (merge a b) rest)]))

(define (main runners what result-dir)
  (define args
    (let ([args (command-line
                 #:args which
                 which)])
      (cond
       [(null? args) (sort (for/list ([k (in-hash-keys runners)]) k)
                           string<?)]
       [else
        (for ([arg args])
          (unless (hash-ref runners arg #f)
            (raise-user-error 'run-micro
                              "unknown ~a: ~a"
                              what
                              arg)))
        args])))

  (make-directory* result-dir)

  (for ([arg args])
    (define ht ((hash-ref runners arg)))
    (with-output-to-file (build-path result-dir arg)
      #:exists 'truncate/replace
      (lambda ()
        (write ht)
        (newline)))))

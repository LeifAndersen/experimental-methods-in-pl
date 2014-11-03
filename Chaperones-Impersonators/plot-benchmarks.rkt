#lang racket

(require math/statistics
         plot)

(define realistic-dir "realistic-plotting-results")

(define collected
  (for/fold ([lst '()])
            ([name (directory-list realistic-dir)])
    (define f (build-path realistic-dir name))
    (append
     lst
     (cond
      [(file-exists? f)
       (define ht (with-input-from-file f read))
       (define ks (sort (for/list ([k (in-hash-keys ht)]) k)
                        string<?
                        #:key symbol->string))
       (for/list ([sub (in-list
                        (let ([vals (hash-iterate-value ht (hash-iterate-first ht))])
                          (if (hash? (car vals))
                              (for/list ([k (in-hash-keys (car vals))])
                                k)
                              (list #f))))])
         (cons
          (format "~a" (if sub sub name))
          (for/list ([k (in-list ks)])
            (define pre-vals (cdr (hash-ref ht k)))
            (define vals (if sub
                             (for/list ([ht (in-list pre-vals)])
                               (hash-ref ht sub))
                             pre-vals))
            (define (all proc ls)
              (list (proc (map car ls))
                    (proc (map cadr ls))
                    (proc (map caddr ls))))
            (define ms (all mean vals))
            (define ss (all stddev vals))
            (list k (car ms) (car ss)))))]
      [else '()]))))

(define converted
  (for/list ([i collected])
    (match i
      [`(,name
         (count   ,m-c   ,st-c)
         (skip-c  ,m-sc  ,st-sc)
         (skip-ca ,m-sca ,st-sca)
         (skip-co ,m-sco ,st-sco))
       `(,name
         ("additional chaperone overhead" ,(- 1 (/ m-sco m-c)))
         ("contract checking overhead"    ,(- 1 (/ m-sca m-sco)))
         ("proxy overhead"                ,(- 1 (/ m-sc  m-sca))))])))

(plot-file
 (for/list ([i converted]
            [j (in-range (length converted))])
     (discrete-histogram (cdr i)
                         #:label (car i)
                         #:x-min j
                         #:color (+ j 1)
                         #:skip  (+ 5 (length converted))))
 "plot.pdf")


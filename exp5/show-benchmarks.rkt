#lang racket

(define micro-dir "micro-results")
(define realistic-dir "realistic-results")

;; discard initkal run:
(define (discard l) (cdr l))

(define (sqr v) (* v v))

(define (mean vals)
  (/ (apply + vals) (length vals)))

(define (std-dev vals)
  (sqrt (- (/ (apply + (map sqr vals)) (length vals))
           (sqr (mean vals)))))

(define (pad v n)
  (substring (string-append (format "~a" v) (make-string n #\space))
             0
             n))

(define (padl v n)
  (define s (string-append (make-string n #\space) (format "~a" v)))
  (substring s
             (- (string-length s) n)))

(for ([name (directory-list micro-dir)])
  (define f (build-path micro-dir name))
  (when (file-exists? f)
    (define ht (with-input-from-file f read))
    (define ks (sort (for/list ([k (in-hash-keys ht)]) k)
                    string<?
                    #:key symbol->string))
    (for ([k (in-list ks)])
      (define vals (discard (hash-ref ht k)))
      (define m (mean vals))
      (define s (std-dev vals))
      (printf "~a ~a: ~a  (+/- ~a%)\n"
              (pad name 13)
              (pad k 20)
              (padl (inexact->exact (floor m)) 8)
              (padl (real->decimal-string (* 100 (/ s m))) 5)))))

(for ([name (directory-list realistic-dir)])
  (define f (build-path realistic-dir name))
  (when (file-exists? f)
    (define ht (with-input-from-file f read))
    (define ks (sort (for/list ([k (in-hash-keys ht)]) k)
                    string<?
                    #:key symbol->string))
    (for ([sub (in-list (let ([vals (hash-iterate-value ht (hash-iterate-first ht))])
                          (if (hash? (car vals))
                              (for/list ([k (in-hash-keys (car vals))])
                                k)
                              (list #f))))])
      (printf "~a:\n" (if sub sub name))
      (for ([k (in-list ks)])
        (define pre-vals (discard (hash-ref ht k)))
        (define vals (if sub
                         (for/list ([ht (in-list pre-vals)])
                           (hash-ref ht sub))
                         pre-vals))
        (define (all proc ls)
          (list (proc (map car ls))
                (proc (map cadr ls))
                (proc (map caddr ls))))
        (define ms (all mean vals))
        (define ss (all std-dev vals))
        (printf " ~a: " (pad k 10))
        (define labels '("cpu" "makes" "apps" "mem"))
        (for ([m ms])
          (printf " ~a"
                  (padl (inexact->exact (floor m)) 8)))
        (printf "  (+/- ")
        (for ([m ms] [s ss]) 
          (printf " ~a%"
                  (padl (real->decimal-string (* 100 (if (zero? m) 0 (/ s m)))) 5)))
        (printf ")\n")))))

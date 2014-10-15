#lang racket
(require "run-utils.rkt")

(define (regexp-must-match rx in)
  (unless (regexp-match? rx in)
    (error 'regexp-must-match "failed: ~e" rx)))

(define rx-sp-num #rx"^ ([0-9]+)")

(define proc-hacks '("count" "skip-co" "skip-ca" "skip-c"))

(define (run-to-string hack prog)
  (with-output-to-string
    (lambda () 
      (system/noisy (format "racket-hack-~a ~a" hack prog)))))

(define (run-and-merge run-one #:hacks [hacks proc-hacks])
  (apply
   merge
   (map (lambda (v) (multi-run (lambda () (run-one v)))) hacks)))

(define (run-guide)
  (define (run-one hack)
    (define out (run-to-string hack "guide.rkt"))
    (define in (open-input-string out))
    (regexp-must-match #rx"pre apps/makes:" in)
    (define pre-apps (extract-number rx-sp-num in))
    (define pre-makes (extract-number rx-sp-num in))
    (define make-cpu (extract-number #rx"cpu time: ([0-9]+)" in))
    (regexp-must-match #rx"mid apps/makes:" in)
    (define mid-apps (extract-number rx-sp-num in))
    (define mid-makes (extract-number rx-sp-num in))
    (define render-cpu (extract-number #rx"cpu time: ([0-9]+)" in))
    (regexp-must-match #rx"post apps/makes:" in)
    (define post-apps (extract-number rx-sp-num in))
    (define post-makes (extract-number rx-sp-num in))
    (hash
     (string->symbol hack)
     (hash 'make-guide
           (list make-cpu
                 (- mid-makes pre-makes)
                 (- mid-apps pre-apps))
           'render-guide
           (list render-cpu
                 (- post-makes mid-makes)
                 (- post-apps mid-apps)))))
  (run-and-merge run-one))

(define (run-plot)
  (define (run-one hack)
    (define out (run-to-string hack "plot.rkt"))
    (define in (open-input-string out))
    (hash
     (string->symbol hack)
     (cons (extract-number #rx"cpu time: ([0-9]+)[^\n]*" in)
           (cadr (read in)))))
  (run-and-merge run-one))

(define (run-typecheck)
  (define (run-one hack)
    (define out (run-to-string hack "tr.rkt"))
    (define in (open-input-string out))
    (define pre (cadr (read in)))
    (define cpu (extract-number #rx"cpu time: ([0-9]+)[^\n]*" in))
    (define post (cadr (read in)))
    (hash 
     (string->symbol hack)
     (list cpu 
           (- (car post) (car pre))
           (- (cadr post) (cadr pre)))))
  (run-and-merge run-one))

(define (run-slideshow)
  (define (run-one hack)
    (define out (run-to-string hack "slideshow/main.rkt"))
    (define in (open-input-string out))
    (define cpu (extract-number #rx"cpu time: ([0-9]+)[^\n]*" in))
    (define stats (cadr (read in)))
    (hash 
     (string->symbol hack)
     (cons cpu stats)))
  (run-and-merge run-one))

(define (run-keyboard)
  ;; check that the tool is installed:
  (collection-path "keystrokes")
  (define (run-one hack)
    (define out (run-to-string hack "-l drracket"))
    (define in (open-input-string out))
    (define pre (read in))
    (define cpu (extract-number #rx"cpu time: ([0-9]+)[^\n]*" in))
    (define post (read in))
    (hash 
     (string->symbol hack)
     (list cpu 
           (- (car post) (car pre))
           (- (cadr post) (cadr pre)))))
  (run-and-merge run-one))

(define (run-ode)
  ;; check that the tool is installed:
  (collection-path "keystrokes")
  (define (run-one hack)
    (define out (run-to-string hack "ode.rkt"))
    (define in (open-input-string out))
    (define cpu (extract-number #rx"cpu time: ([0-9]+)[^\n]*" in))
    (read-line in)
    (read-line in)
    (read-line in)
    (define stats (cadr (read in)))
    (hash 
     (string->symbol hack)
     (list cpu (car stats) (cadr stats))))
  (run-and-merge run-one #:hacks '("count" "skip-co" "skip-vca" "skip-vc" "skip-cvc")))

(define (run-lazy)
  (define (run-one variant)
    (define (run-half which)
      (run-to-string "count" 
                     (format 
                      "struct/pff.rkt --stdout --~a struct/koala-face.trace.gz ~s 0"
                      which
                      variant)))
    (define time-out (run-half "chap"))
    (define mem-out (run-half "mem"))
    (define time-in (open-input-string time-out))
    (define mem-in (open-input-string mem-out))
    (read-line time-in)
    (define stats (read time-in))
    (define cpu (read time-in))
    (read-line mem-in)
    (define mem (read mem-in))
    (hash
     (string->symbol variant)
     (list cpu 
           (list-ref stats 4)
           (list-ref stats 5)
           mem)))
  (run-and-merge run-one #:hacks '("opt chap" "opt" "none")))

(define runners
  (hash "guide" run-guide
        "keyboard" run-keyboard
        "plot" run-plot
        "typecheck" run-typecheck
        "slideshow" run-slideshow
        "ode" run-ode
        "lazy" run-lazy))

(main runners "benchmark" "realistic-results")

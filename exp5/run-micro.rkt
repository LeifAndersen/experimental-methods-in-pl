#lang racket
(require "run-utils.rkt")

(define v8-cmd "v8-shell --harmony")
(define spidermonkey-cmd "js -m -n")

(define all-proc-micro '(direct indirect wrapped wrapped+check wrapped+return))


(define (run-racket* hack?)
  (define (run-multi what modes cvt)
    (define out (with-output-to-string
                  (lambda () 
                    (system/noisy (format "racket~a ~a-bm.rkt" 
                                          (if hack? "-hack-jit" "")
                                          what)))))
    (define in (open-input-string out))
    (for/hash ([t modes])
      (values (cvt t)
              (extract-number (regexp (format "'~a\ncpu time: ([0-9]+)" 
                                              (regexp-quote (symbol->string t))))
                              in))))
  (define (run-proc)
    (run-multi "proc"
               (append all-proc-micro
                       '(impersonate impersonate+return
                                     chaperone chaperone+return))
               (lambda (n) n)))
  (define (run-struct)
    (run-multi "struct"
               '(direct chaperone unsafe unsafe*)
               (lambda (n) (string->symbol (format "struct-~a" n)))))

  (define (run-prog name base suffix)
    (define out (with-output-to-string
                  (lambda () (system/noisy (format "racket~a ~a~a.rkt" 
                                                   (if hack? "-hack-jit" "")
                                                   base
                                                   suffix)))))
    (hash name
          (extract-number #rx#"cpu time: ([0-9]+)" out)))

  (define (run-church name suffix)
    (run-prog name "church" suffix))
  (define (run-bubble name suffix)
    (run-prog name "bubble" suffix))

  (void (system/noisy "raco make proc-bm.rkt church.rkt church-wrap.rkt"))
  (void (system/noisy "raco make church-chap.rkt church-chap-a.rkt church-contract.rkt"))
  (void (system/noisy "raco make bubble.rkt bubble-chap.rkt bubble-unsafe.rkt bubble-unsafe2.rkt"))
  (void (system/noisy "raco make struct-bm.rkt"))

  (if hack?
      (merge
       (multi-run (lambda () (run-bubble 'bubble "")))
       (multi-run (lambda () (run-bubble 'bubble-chaperone "-chap"))))
      (merge
       (multi-run (lambda () (run-proc)))
       (multi-run (lambda () (run-church 'church "")))
       (multi-run (lambda () (run-church 'church-wrap "-wrap")))
       (multi-run (lambda () (run-church 'church-chaperone "-chap")))
       (multi-run (lambda () (run-church 'church-chaperone/a "-chap-a")))
       (multi-run (lambda () (run-church 'church-contract "-contract")))
       (multi-run (lambda () (run-bubble 'bubble "")))
       (multi-run (lambda () (run-bubble 'bubble-chaperone "-chap")))
       (multi-run (lambda () (run-bubble 'bubble-unsafe "-unsafe")))
       (multi-run (lambda () (run-bubble 'bubble-unsafe* "-unsafe2")))
       (multi-run (lambda () (run-struct))))))

(define (run-racket)
  (run-racket* #f))

(define (run-racket-hack-jit)
  (run-racket* #t))

(define (run-larceny)
  (define larceny-cmd "larceny -r6rs -program")
  (define rx #rx#"^Words allocated: [0-9]+\nElapsed time...: ([0-9]+) ms")
  (define (run-proc)
    (define out
      (with-output-to-string
        (lambda ()
          (system/noisy (format "~a proc-bm.sch" larceny-cmd)))))
    (define in (open-input-string out))
    (for/hash ([t all-proc-micro])
      (regexp-match (regexp (format "~a\n" (regexp-quote (symbol->string t)))) in)
      (values t (extract-number rx in))))
  (define (run-prog name base suffix ext)
    (define out
      (with-output-to-string
        (lambda ()
          (system/noisy (format "~a ~a~a~a"
                                larceny-cmd
                                base
                                suffix
                                ext)))))
    (hash name (extract-number rx out)))
  (define (run-church name suffix)
    (run-prog name "church" suffix ".sch"))
  (define (run-bubble name ext)
    (run-prog name "bubble" "" ext))
  (define (run-struct name ext)
    (run-prog name "struct-bm" "" ext))
  (system/noisy (format "~a mk-unsafe.sch" larceny-cmd))
  (begin0
   (merge
    (multi-run (lambda () (run-proc)))
    (multi-run (lambda () (run-church 'church ""))) 
    (multi-run (lambda () (run-church 'church-wrap "-wrap")))
    (multi-run (lambda () (run-bubble 'bubble ".sch")))
    (multi-run (lambda () (run-bubble 'bubble-unsafe ".slfasl")))
    (multi-run (lambda () (run-struct 'struct-direct ".sch")))
    (multi-run (lambda () (run-struct 'struct-unsafe ".slfasl"))))
   (begin
     (delete-file "bubble.slfasl")
     (delete-file "struct-bm.slfasl"))))

(define (run-chicken)
  (define rx #rx#"^([0-9.]+)s CPU time,")
  (define (run-proc)
    (define out
      (with-output-to-string
        (lambda ()
          (system/err-as-out "./proc-bm"))))
    (define in (open-input-string out))
    (for/hash ([t all-proc-micro])
      (regexp-match (regexp (format "~a\n" (regexp-quote (symbol->string t)))) in)
      (values t (extract-number rx in #:multiply 1000))))
  (define (run-prog name prog)
    (define out
      (with-output-to-string
        (lambda ()
          (system/err-as-out (format "./~a" prog)))))
    (hash name (extract-number rx out #:multiply 1000)))
  (define (run-church name suffix)
    (run-prog name (string-append "church" suffix)))
  
  (system/noisy "csc -O3 -no-trace proc-bm.scm")
  (system/noisy "csc -O3 -no-trace church.scm")
  (system/noisy "csc -O3 -no-trace church-wrap.scm")
  (system/noisy "csc -O3 -no-trace bubble.scm")
  (system/noisy "csc -O3 -no-trace -unsafe -o bubble-unsafe bubble.scm")
  (system/noisy "csc -O3 -no-trace struct-bm.scm")
  (system/noisy "csc -O3 -no-trace -unsafe -o struct-unsafe struct-bm.scm")
  
  (begin0
   (merge
    (multi-run (lambda () (run-proc)))
    (multi-run (lambda () (run-church 'church ""))) 
    (multi-run (lambda () (run-church 'church-wrap "-wrap")))
    (multi-run (lambda () (run-prog 'bubble "bubble")))
    (multi-run (lambda () (run-prog 'bubble-unsafe "bubble-unsafe")))
    (multi-run (lambda () (run-prog 'struct-direct "struct-bm")))
    (multi-run (lambda () (run-prog 'struct-unsafe "struct-unsafe"))))
   (begin
     (delete-file "proc-bm")
     (delete-file "church")
     (delete-file "church-wrap")
     (delete-file "bubble")
     (delete-file "bubble-unsafe")
     (delete-file "struct-bm")
     (delete-file "struct-unsafe"))))

(define (run-js cmd extra-contract-args)
  (define rx #rx#"^([0-9]+)\n")
  (define (run-multi what modes cvt)
    (define out
      (with-output-to-string
        (lambda ()
          (system/noisy (format "~a ~a-bm.js" cmd what)))))
    (define in (open-input-string out))
    (for/hash ([t modes])
      (regexp-match (regexp (format "~a\n" (regexp-quote (symbol->string t)))) in)
      (values (cvt t) (extract-number rx in))))
  (define (run-proc)
    (run-multi "proc" (append all-proc-micro '(proxy)) (lambda (v) v)))
  (define (run-struct)
    (run-multi "struct" '(direct proxy) (lambda (v)
                                          (string->symbol (format "struct-~a" v)))))
  (define (run-prog name prog args expect-rx)
    (define out
      (with-output-to-string
        (lambda ()
          (system/noisy (format "~a ~a ~a.js" cmd args prog)))))
    (define in (open-input-string out))
    (when expect-rx
      (unless (regexp-match expect-rx in) (error "wrong answer")))
    (hash name (extract-number rx in)))
  (define (run-church name suffix args)
    (run-prog name (string-append "church" suffix) args #rx"362880\n"))
  (merge
   (multi-run (lambda () (run-proc)))
   (multi-run (lambda () (run-church 'church "" ""))) 
   (multi-run (lambda () (run-church 'church-wrap "-wrap" "")))
   (multi-run (lambda () (run-church 'church-proxy "-proxy" "")))
   (multi-run (lambda () (run-church 'church-contract "_harness" extra-contract-args)))
   (multi-run (lambda () (run-prog 'bubble "bubble" "" #f)))
   (multi-run (lambda () (run-prog 'bubble-proxy "bubble-proxy" "" #f)))
   (multi-run (lambda () (run-struct)))))

(define (run-v8)
  (run-js v8-cmd "--noincremental-marking"))

(define (run-spidermonkey)
  (run-js spidermonkey-cmd ""))

(define runners
  (hash "racket" run-racket
        "racket-hack-jit" run-racket-hack-jit
        "larceny" run-larceny
        "chicken" run-chicken
        "v8" run-v8
        "spidermonkey" run-spidermonkey))

(main runners "implementation" "micro-results")

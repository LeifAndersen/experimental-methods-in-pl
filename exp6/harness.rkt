#lang racket

(require benchmark
         racket/runtime-path
         compiler/find-exe
         plot)

(define test-paths
  '("examples/loop-add"))

(define-runtime-path results-file "results")
(define-runtime-path plot-file*   "plot.pdf")

(define-runtime-path compiled-dir "examples/compiled")

(define results
  (run-benchmarks
   test-paths
   '((jit no-jit)
     (set! fold)
     (primitives functions classes))
   (λ (file jit update abstraction)
     (match `(,jit ,update ,abstraction)
       ['(jit set! primitives)
        (system* (find-exe) (format "~a.rkt" file))]
       ['(jit fold primitives)
        (system* (find-exe) (format "~a-fold.rkt" file))]
       ['(jit set! functions)
        (system* (find-exe) (format "~a-func.rkt" file))]
       ['(jit fold functions)
        (system* (find-exe) (format "~a-func-fold.rkt" file))]
       ['(jit set! classes)
        (system* (find-exe) (format "~a-class.rkt" file))]
       ['(jit fold classes)
        (system* (find-exe) (format "~a-class-fold.rkt" file))]
       ['(no-jit set! primitives)
        (system* (find-exe) "-j" (format "~a.rkt" file))]
       ['(no-jit fold primitives)
        (system* (find-exe) "-j" (format "~a-fold.rkt" file))]
       ['(no-jit set! functions)
        (system* (find-exe) "-j" (format "~a-func.rkt" file))]
       ['(no-jit fold functions)
        (system* (find-exe) "-j" (format "~a-func-fold.rkt" file))]
       ['(no-jit set! classes)
        (system* (find-exe) "-j" (format "~a-class.rkt" file))]
       ['(no-jit fold classes)
        (system* (find-exe) "-j" (format "~a-class-fold.rkt" file))]))
   #:build (λ (file jit update abstraction)
             (match `(,update ,abstraction)
               ['(set! primitives) (system* (find-exe)  "-l" "raco" "make"
                                            (format "~a.rkt" file))]
               ['(fold primitives) (system* (find-exe) "-l" "raco" "make"
                                            (format "~a-fold.rkt" file))]
               ['(set! functions)  (system* (find-exe)  "-l" "raco" "make"
                                            (format "~a-func.rkt" file))]
               ['(fold functions)  (system* (find-exe) "-l" "raco" "make"
                                            (format "~a-func-fold.rkt" file))]
               ['(set! classes)    (system* (find-exe) "-l" "raco" "make"
                                            (format "~a-class.rkt" file))]
               ['(fold classes)    (system* (find-exe) "-l" "raco" "make"
                                            (format "~a-class-fold.rkt" file))]))
   #:clean (λ (file jit update abstraction)
             (delete-directory/files compiled-dir))
   #:num-trials 50
   #:make-name (λ (path)
                 (let-values ([(path-name file-name root?) (split-path path)])
                   (path->string file-name)))
   #:results-file results-file))

;;(define results (get-past-results results-file))

(define results/plot
  (parameterize ([plot-x-ticks no-ticks])
    (plot-file
     #:title "JIT and Contracts"
     #:x-label #f
     #:y-label "normalized time"
     (render-benchmark-alts
      '(jit set! primitives)
      results
      #:normalize? #t)
     plot-file*)))

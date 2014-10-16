#lang racket

(require benchmark
         racket/runtime-path
         compiler/find-exe
         plot)

(define test-paths
  '("examples/prog.rkt"))

(define functions (range 200 1000 200))
(define f-length  (range 4 20 4))
(define f-calls   (range 400 2000 400))

(define-runtime-path results-file "results")
(define-runtime-path plot-file*   "plot.pdf")

(define-runtime-path compiled-dir "examples/compiled")

(define (number->bytes/utf-8 n)
  (string->bytes/utf-8 (number->string n)))

(define results
  (run-benchmarks
   test-paths
   `((jit no-jit)
     ,functions
     ,f-length
     ,f-calls)
   (λ (file jit functions f-length f-calls)
     (match jit
       ['jit    (system* (find-exe)      file)]
       ['no-jit (system* (find-exe) "-j" file)]))
   #:build
   (λ (file jit functions f-length f-calls)
     (parameterize ([current-environment-variables
                     (make-environment-variables
                      #"FUNCTIONS" (number->bytes/utf-8 functions)
                      #"FLENGTH"   (number->bytes/utf-8 f-length)
                      #"FCALLS"    (number->bytes/utf-8 f-calls))])
       (system* (find-exe) "-l" "raco" "make" file)))
   #:clean
   (λ (file jit functions f-length f-calls)
     (delete-directory/files compiled-dir))
   #:num-trials 30
   #:make-name (λ (path)
                 (let-values ([(path-name file-name root?) (split-path path)])
                   (path->string file-name)))
   #:results-file results-file))

;;(define results (get-past-results results-file))

(define results/plot
  (parameterize ([plot-x-ticks no-ticks])
    (plot-file
     #:title "JIT"
     #:x-label #f
     #:y-label "Time"
     (render-benchmark-alts
      '(jit functions f-length f-calls)
      results
      #:normalize? #f)
     plot-file*)))

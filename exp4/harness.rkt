#lang racket

(require benchmark
         racket/runtime-path
         compiler/find-exe
         plot)

(define test-paths
  '("funky-town.rkt"
    "lazy.rkt"
    "make-guide.rkt"
    "ode.rkt"
    "plot.rkt"
    "render-guide.rkt"
    "slideshow.rkt"
    "tr.rkt"))

(define-runtime-path results-file "results")
(define-runtime-path plot-file*   "plot.pdf")

(define-runtime-path compiled-dir "examples/compiled")

(define results
  (run-benchmarks
   test-paths
   '((jit no-jit))
   (λ (file jit)
     (match jit
       ['jit                (system* (find-exe)      file)]
       ['no-jit             (system* (find-exe) "-j" file)]))
   #:build (λ (file jit contracts)
             (system* (find-exe) "-l" "raco" "make" file))
   #:clean (λ (file jit contracts)
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
      '(jit)
      results
      #:normalize? #f)
     plot-file*)))

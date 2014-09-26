#lang racket

(require benchmark
         racket/runtime-path
         compiler/find-exe
         plot)

(define test-paths
  '("examples/matrix"))

(define-runtime-path results-file "results")
(define-runtime-path plot-file*   "plot.pdf")

(define-runtime-path compiled-dir "examples/compiled")

(define results
  (run-benchmarks
   test-paths
   '((jit no-jit)
     (contracts no-contracts no-contracts+optimize))
   (λ (file jit contracts)
     (match `(,jit ,contracts)
       ['(jit contracts)                (system* (find-exe)      (format "~a.rkt"          file))]
       ['(no-jit contracts)             (system* (find-exe) "-j" (format "~a.rkt"          file))]
       ['(jit no-contracts)             (system* (find-exe)      (format "~a-typed.rkt"    file))]
       ['(no-jit no-contracts)          (system* (find-exe) "-j" (format "~a-typed.rkt"    file))]
       ['(jit no-contracts+optimize)    (system* (find-exe)      (format "~a-optimize.rkt" file))]
       ['(no-jit no-contracts+optimize) (system* (find-exe) "-j" (format "~a-optimize.rkt" file))]))
   #:build (λ (file jit contracts)
             (system* (find-exe) "-l" "raco" "make" (format "~a.rkt" file))
             (system* (find-exe) "-l" "raco" "make" (format "~a-typed.rkt" file)))
   #:clean (λ (file jit contracts)
             (delete-directory/files compiled-dir))
   #:num-trials 30
   #:make-name (λ (path)
                 (let-values ([(path-name file-name root?) (split-path path)])
                   (path->string file-name)))
   #:results-file results-file))

;;(define results (get-post-results results-file))

(define results/plot
  (parameterize ([plot-x-ticks no-ticks])
    (plot-file
     #:title "JIT and Contracts"
     #:x-label #f
     #:y-label "normalized time"
     (render-benchmark-alts
      '(jit contracts)
      results)
     plot-file*)))

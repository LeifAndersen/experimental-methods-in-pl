#lang racket

(require benchmark
         racket/runtime-path
         compiler/find-exe
         plot)

(define test-paths
  '("examples/bt-esp.rkt"
    "examples/bt-esp-off.rkt"))

(define-runtime-path results-file "results")
(define-runtime-path plot-file*   "plot.pdf")

(define-runtime-path compiled-dir "examples/compiled")

(define results
  (run-benchmarks
   test-paths
   '((0 5 10 15 20))
   (λ (file t)
     (system* (find-exe) file (number->string t)))
   #:build (λ (file t)
             (system* (find-exe) "-l" "raco" "make" file))
   #:clean (λ (file t)
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
     #:title "Struct Logging Times"
     #:x-label #f
     #:y-label "normalized time"
     (render-benchmark-alts
      '(0)
      results
      #:normalize? #f)
     plot-file*)))

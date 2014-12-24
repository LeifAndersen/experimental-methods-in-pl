#lang racket

(require benchmark
         racket/runtime-path
         compiler/find-exe
         plot)

(define test-paths
  '("examples/appendtest-fairconj"))

(define-runtime-path results-file "results")
(define-runtime-path plot-file*   "plot.pdf")

(define-runtime-path compiled-dir "examples/compiled")
(define-runtime-path dKanren-dir "examples/dKanren/compiled")
(define-runtime-path dKanren-off-dir "examples/dKanren-off/compiled")

(define results
  (run-benchmarks
   test-paths
   '((contracts no-contracts no-optimize))
   (λ (file contracts)
     (match contracts
       ['contracts     (system* (find-exe)      (format "~a.rkt"        file))]
       ['no-contracts  (system* (find-exe)      (format "~a-off.rkt"    file))]
       ['no-optimize   (system* (find-exe)      (format "~a-off.rkt"    file))]))
   #:build
   (λ (file contracts)
     (match contracts
       ['contracts (system* (find-exe) "-l" "raco" "make" (format "~a.rkt" file))]
       ['no-optimize  (system* (find-exe) "-l" "raco" "make" "--disable-inline" (format "~a-off.rkt" file))]
       ['no-contracts (system* (find-exe) "-l" "raco" "make" (format "~a-off.rkt" file))]))
   #:clean
   (λ (file contracts)
     (delete-directory/files compiled-dir)
     (match contracts
       ['contracts (delete-directory/files dKanren-dir)]
       ['no-contracts (delete-directory/files dKanren-off-dir)]
       ['no-optimize (delete-directory/files dKanren-off-dir)]))
   #:num-trials 50
   #:make-name (λ (path)
                 (let-values ([(path-name file-name root?) (split-path path)])
                   (path->string file-name)))
   #:results-file results-file))

;;(define results (get-past-results results-file))

(define results/plot
  (parameterize ([plot-x-ticks no-ticks])
    (plot-file
     #:title "Contracts on dKanren"
     #:x-label #f
     #:y-label "normalized time"
     (render-benchmark-alts
      '(contracts)
      results
      #:normalize? #f)
     plot-file*)))

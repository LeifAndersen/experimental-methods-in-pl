#lang racket/base

(require racket/file
         racket/string
         racket/system
         racket/list
         math/statistics)

;; Number of times to run each argument file
(define NSAMPLES 30)
;; Temporary file to store results of each run
(define TMPFILE "tmp.out")
;; Separator for output 'spreadsheet'
(define SEP "\t")
;; Racket, with and without contracts
(define rkt+c "racket")
(define rkt-c "noc-racket")

;; Compute a 95% confidence interval
(define (confidence-95 samples)
  ; z is constant for 95% confidence
  (define z 1.96)
  ; sample parameters: num samples, mean, std. deviation
  (define n (length samples))
  (define u (mean samples))
  (define o (stddev/mean u samples))
  ; magnitude of CI
  (define offset (/ (* z o) (sqrt n)))
  ; return lower + upper bound. 95% confident that the true mean is more than 'car' and less than 'cdr'
  (values (- u offset) (+ u offset)))

;; Expecting a string of `time` output. Return the CPU time (milliseconds)
;; Should look like "cpu time: 49 real time: 50 gc time: 37\n"
(define (parse-cpu-time str)
  (with-handlers ([exn:fail? (lambda (v) (error (format "Error parsing cpu time from string '~a'." str)))])
    (string->number (car (string-split (string-trim str "cpu time: " #:right? #f))))))

;; Run one trial on 'filename'. Return the CPU time for this experiment.
(define (run-one jit? contract? i filename)
  (begin
    (printf "Running trial [~a/~a]...\n" i NSAMPLES)
    ;; Run `racket`. Parameterized by jit and contract settings.
    (system (format "~a ~a ~a > ~a"
                    (if contract? rkt+c rkt-c)
                    (if jit?      ""    "--no-jit")
                    filename
                    TMPFILE))
    (define result (parse-cpu-time (file->string TMPFILE)))
    (system (format "rm ~a" TMPFILE))
    (printf "cpu time (ms): ~a\n" result)
    result))

;; Run NSAMPLES trials on 'filename'. Return a list of CPU time for each experiement.
(define (run-file jit? contract? filename)
  (printf "Running file '~a' with JIT ~a and CONTRACTS ~a...\n"
          filename
          (if jit? "enabled" "disabled")
          (if contract? "enabled" "disabled"))
  (for/list ([i (in-range NSAMPLES)])
    (run-one jit? contract? i filename)))

;; Write all results to 'filename'.
;; Collect averages & 95% confidence intervals.
(define (write-totals filename c+results c-results)
  (with-output-to-file filename #:exists 'replace
    (lambda ()
      (begin
        ;; Collect and print aggregate information
        (define c+avg (mean c+results))
        (define-values (c+lci c+uci) (confidence-95 c+results))
        (define c-avg (round (mean c-results)))
        (define-values (c-lci c-uci) (confidence-95 c-results))
        (printf (string-join (list "+C Avg. Runtime" "+C lower CI" "+C upper CI")
                             SEP))
        (displayln "")
        (printf (string-join (map (lambda (n) (number->string (round n)))
                                  (list c+avg c+lci c+uci))
                             SEP))
        (displayln "")
        (printf (string-join (list "-C Avg. Runtime" "-C lower CI" "-C upper CI")
                             SEP))
        (displayln "")
        (printf (string-join (map (lambda (n) (number->string (round n)))
                                  (list c-avg c-lci c-uci))
                             SEP))
        ;; Print rest of results
        (displayln "")
        (displayln "")
        (printf (string-join (list "Trail"
                                   "C+ Runtime"
                                   "C- Runtime")
                             SEP))
        (for ([i (in-range 0 (max (length c+results) (length c-results)))]
              [c+val c+results]
              [c-val c-results])
          (begin (displayln "")
                 (printf (string-join (map number->string (list i c+val c-val))
                                      SEP))))))))

;; Run "racket filename" NSAMPLES times. Aggregate results & report 95% confidence interval
(define (run-and-collect jit? filename)
  (begin
    ;; Run trials
    (define contract-output (run-file jit? #t filename))
    (define nocontract-output (run-file jit? #f filename))
    ;; Write total results
    (printf "Finished collecting, aggregating output...\n")
    (define out-file (format "output-~a-~a.tab" (if jit? "jit" "nojit") filename))
    (write-totals out-file contract-output nocontract-output)
    (printf "ALL DONE! See '~a' for results.\n" out-file)
  ))

;; Print usage information
(define (print-help)
  (displayln "Usage: controller.rkt <filename> ..."))

;; get filenames from the command-line
(define args (vector->list (current-command-line-arguments)))
(cond [(empty? args) (print-help)]
      [(< NSAMPLES 1) (printf "ERROR: need a positive number of samples\n")]
      [else          (for ([arg args]) (begin (run-and-collect #t arg)
                                              (run-and-collect #f arg)))])

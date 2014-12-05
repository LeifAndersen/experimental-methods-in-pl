; strcat.scm

;;; SPECIFICATION

;For this test, each program should be implemented in the same way,
;according to the following specification.
;
;    pseudocode for strcat test
;
;   s is initialized to the null string
;   repeat N times:
;     append "hello\n" to s
;   count the number of individual characters in s
;   print the count

;  There should be N distinct string append statements done in a loop.
;  After each append the resultant string should be 6 characters
;  longer (the length of "hello\n").
;  s should be a string, string buffer, or character array.
;  The program should not construct a list of strings and join it.

#lang racket/base

(require racket/contract)

(define p (open-output-bytes))

(define hello #"hello\n")

(define/contract (main n)
  (-> natural-number/c void?)
  (unless (zero? n)
    (display hello p)
    ;; At this point, (get-output-bytes p) would
    ;; return the byte string accumulated so far.
    (main (sub1 n))))

(time (begin (main 50000000) (void)))

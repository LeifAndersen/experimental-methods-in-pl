#lang racket

(require dlm-read
         plot
         pict)

(define x (dlm-read "bar.txt"))

(append
 (for/list ([i x])
   (plot (points (map list i (range (length i)))))))
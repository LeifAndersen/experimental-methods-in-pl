#lang racket/base
(require (only-in racket/unsafe/ops
                  unsafe-struct-ref
                  unsafe-struct*-ref))

(struct fish (weight color) #:mutable)

(define N 100000000)

(define (loop f)
  (time
   (for ([i (in-range N)])
     (fish-weight f))))

'direct
(loop (fish 1 "blue"))

'impersonate
(loop (impersonate-struct (fish 1 "blue")
                          fish-weight (lambda (f v) v)
                          set-fish-weight! (lambda (f v) v)))

'chaperone
(loop (chaperone-struct (fish 1 "blue")
                        fish-weight (lambda (f v) v)))

'unsafe
(define (unsafe-loop f)
  (time
   (for ([i (in-range N)])
     (unsafe-struct-ref f 0))))

(unsafe-loop (fish 1 "blue"))

'unsafe*
(define (unsafe*-loop f)
  (time
   (for ([i (in-range N)])
     (unsafe-struct*-ref f 0))))

(unsafe*-loop (fish 1 "blue"))

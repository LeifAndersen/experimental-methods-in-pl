#lang racket

(require math/array)

(provide mix)

;; Weighted sum of signals, receives a list of lists (signal weight).
;; Shorter signals are repeated to match the length of the longest.
;; Normalizes output to be within [-1,1].

(define (mix . ss)

  (define signals (map first ss))
  (define weights (map (lambda (x) (real->double-flonum (second x))) ss))
  (define downscale-ratio (/ 1.0 (apply + weights)))

  (define ((scale-signal w) x) (* x w downscale-ratio))

  (parameterize ([array-broadcasting 'permissive]) ; repeat short signals
    (for/fold ([res (array-map (scale-signal (first weights))
                               (first signals))])
        ([s (rest signals)]
         [w (rest weights)])
      (define scale (scale-signal w))
      (array-map (lambda (acc new) (+ acc (scale new)))
                 res s))))

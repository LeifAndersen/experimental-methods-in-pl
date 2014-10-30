#lang racket

(require ffi/unsafe)
(define (stats)
  (list (get-ffi-obj 'proc_makes #f _int)
        (get-ffi-obj 'proc_apps #f _int)
        (get-ffi-obj 'struct_makes #f _int)
        (get-ffi-obj 'struct_apps #f _int)
        (get-ffi-obj 'vec_makes #f _int)
        (get-ffi-obj 'vec_apps #f _int)))

(stats)
(collect-garbage)
(time (dynamic-require 'tests/typed-racket/succeed/new-metrics #f))
(stats)


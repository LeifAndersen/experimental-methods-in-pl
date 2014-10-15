#lang racket/base
(require racket/class
         racket/draw
         plot
         slideshow/pict
         (prefix-in file: file/convertible))

'make
(define p 
  (begin ; time 
   (plot3d-pict (isosurfaces3d (compose abs max) -1 1 -1 1 -1 1))))
'to-png
(define bstr
  (time (file:convert p 'png-bytes)))

(require ffi/unsafe)
(list (get-ffi-obj 'proc_makes #f _int)
      (get-ffi-obj 'proc_apps #f _int))



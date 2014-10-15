#lang racket
(require scribble/render
         ffi/unsafe)

(define ns (current-namespace))

(define stats?
  (and (get-ffi-obj 'proc_apps #f _int (lambda () #f)) #t))

(let loop ()
  (sync (system-idle-evt))
  (collect-garbage)
  (sync (system-idle-evt))
  (collect-garbage)
  (when stats?
    (printf "pre apps/makes: ~s ~s\n" (get-ffi-obj 'proc_apps #f _int) (get-ffi-obj 'proc_makes #f _int)))
  (parameterize ([current-namespace (make-base-namespace)])
    (namespace-attach-module ns 'scribble/render)
    (define doc (time (dynamic-require '(lib "scribblings/guide/guide.scrbl")
                                       'doc)))
    (when stats?
      (printf "mid apps/makes: ~s ~s\n" (get-ffi-obj 'proc_apps #f _int) (get-ffi-obj 'proc_makes #f _int)))
    (time
     (render (list doc)
             (list "file")
             #:dest-dir "/tmp")))
  (when stats?
    (printf "post apps/makes: ~s ~s\n" (get-ffi-obj 'proc_apps #f _int) (get-ffi-obj 'proc_makes #f _int))))

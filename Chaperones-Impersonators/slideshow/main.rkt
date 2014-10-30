#lang slideshow
(require "movie.rkt"
         "analogy.rkt"
         "plt.rkt"
         "end.rkt"
         "peek.rkt")

(slide (blank))
(time
 (begin
   (movie-slides (slide->pict (retract-most-recent-slide)))
   (analogy-slides)
   (plt-slides)
   (end-slides)
   (peek-slides final-end-slide)))

(require ffi/unsafe)
(list (get-ffi-obj 'proc_makes #f _int)
      (get-ffi-obj 'proc_apps #f _int))
(exit)


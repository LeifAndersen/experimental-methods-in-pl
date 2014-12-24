#lang racket

(require plot
         math
         dlm-read)

(define (build-res exp)
  (define jit (dlm-read (format "output-jit-~a.rkt.tab" exp)))
  (define nojit (dlm-read (format "output-nojit-~a.rkt.tab" exp)))
  (list (first jit) (second jit) (third jit) (second nojit) (third nojit)))

(define (plot-res exp m name label?)
  (define (dh #:x-min x-min #:color c #:line-color lc
              #:label l #:label? l? arg)
    (if l?
        (discrete-histogram
         #:x-min x-min
         #:color c
         #:line-color lc
         #:label l
         arg)
        (discrete-histogram
         #:x-min x-min
         #:color c
         #:line-color lc
         arg)))

  (define avg (mean (second m)))
  (define jca (/ (mean (second m)) avg))
  (define jna (/ (mean (third m)) avg))
  (define nja (/ (mean (fourth m)) avg))
  (define nna (/ (mean (fifth m)) avg))
  (define jcs (/ (stddev (second m)) avg))
  (define jns (/ (stddev (third m)) avg))
  (define njs (/ (stddev (fourth m)) avg))
  (define nns (/ (stddev (fifth m)) avg))
  (define off (* exp 5.5))
  (list (dh
         #:x-min off #:color 1 #:line-color 1
         #:label "JIT+Contracts" #:label? label?
         `((,name ,jca)))
        (dh
         #:x-min (+ off 1) #:color 2 #:line-color 2
         #:label "JIT+No Contracts" #:label? label?
         `((,name ,jna)))
        (dh
         #:x-min (+ off 2) #:color 3 #:line-color 3
         #:label "No JIT+Contracts" #:label? label?
         `((,name ,nja)))
        (dh
         #:x-min (+ off 3) #:color 4 #:line-color 4
         #:label "No JIT+No Contracts" #:label? label?
         `((,name ,nna)))
        (error-bars
         `((,(+ off 0.5) ,jca ,jcs)
           (,(+ off 1.5) ,jna ,jns)
           (,(+ off 2.5) ,nja ,njs)
           (,(+ off 3.5) ,nna ,nns)))))

(define pe27 (build-res "27"))
(define pe33 (build-res "33"))
(define pe34 (build-res "34"))
(define pe46 (build-res "46"))
(define snake (build-res "run-snake"))
(define tetris (build-res "run-tetris"))
(define zombie (build-res "run-zombie"))

(parameterize ([plot-x-ticks no-ticks])
  (plot-file
   #:x-label ""
   #:y-label "Time (Normalized to JIT+Contracts)"
   #:width (* 2 (plot-width))
   (append
    (plot-res 0 pe27 "Project Euler #27" #t)
    (plot-res 1 pe33 "Project Euler #33" #f)
    (plot-res 2 pe34 "Project Euler #34" #f)
    (plot-res 3 pe46 "Project Euler #46" #f)
    (plot-res 4 snake "Snake" #f)
    (plot-res 5 tetris "Tetris" #f)
    (plot-res 6 zombie "Zombie" #f))
   "results.png"))

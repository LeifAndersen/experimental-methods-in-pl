#lang racket/base

;;; The Computer Language Benchmarks Game
;;; http://shootout.alioth.debian.org/
;;;
;;; Uses Racket threads

(require racket/cmdline
         racket/contract
         racket/match)

(define color? (or/c 'red 'blue 'yellow))
(define creature/c (cons/c color? symbol?))
(define chn/c (channel/c (cons/c (channel/c (or/c false/c creature/c)) creature/c)))

(define/contract (change c1 c2)
  (-> color? color? color?)
  (case c1
    [(red)
     (case c2 [(blue) 'yellow] [(yellow) 'blue] [else c1])]
    [(yellow)
     (case c2 [(blue) 'red] [(red) 'blue] [else c1])]
    [(blue)
     (case c2 [(yellow) 'red] [(red) 'yellow] [else c1])]))
  
(let ([colors '(blue red yellow)])
  (for* ([a colors][b colors])
    (format "~a + ~a -> ~a\n" a b (change a b))))

(define/contract (place meeting-ch n)
  (-> chn/c exact-nonnegative-integer? thread?)
  (thread
   (lambda ()
     (let loop ([n n])
       (if (zero? n)
           ;; Fade all:
           (let loop ()
             (let ([c (channel-get meeting-ch)])
               (channel-put (car c) #f)
               (loop)))
           ;; Let two meet:
           (match-let ([(cons ch1 v1) (channel-get meeting-ch)]
                       [(cons ch2 v2) (channel-get meeting-ch)])
             (channel-put ch1 v2)
             (channel-put ch2 v1)
             (loop (sub1 n))))))))

(define/contract (creature color meeting-ch result-ch)
  (-> color? chn/c (channel/c (cons/c integer? integer?)) thread?) ; TODO
  (thread 
   (lambda ()
     (let ([ch (make-channel)]
           [name (gensym)])
       (let loop ([color color][met 0][same 0])
         (channel-put meeting-ch (cons ch (cons color name)))
         (match (channel-get ch)
           [(cons other-color other-name)
            ;; Meet:
            (sleep) ; avoid imbalance from weak fairness
            (loop (change color other-color) 
                  (add1 met)
                  (+ same (if (eq? name other-name)
                              1
                              0)))]
           [#f
            ;; Done:
            (channel-put result-ch (cons met same))]))))))

(define (spell n)
  (-> exact-nonnegative-integer? none/c)
  (for ([i (number->string n)])
    (format " ")
    (format "~a" (hash-ref digits i))))
  
(define digits
  #hash((#\0 . "zero")
        (#\1 . "one")
        (#\2 . "two")
        (#\3 . "three")
        (#\4 . "four")
        (#\5 . "five")
        (#\6 . "six")
        (#\7 . "seven")
        (#\8 . "eight")
        (#\9 . "nine")))

(define/contract (go n inits)
  (-> exact-nonnegative-integer? (listof color?) void?)
  (let ([result-ch (make-channel)]
        [meeting-ch (make-channel)])
    (place meeting-ch n)
    ; (newline)
    (for ([init inits])
      (format " ~a" init)
      (creature init meeting-ch result-ch))
    ; (newline)
    (let ([results (for/list ([i inits])
                     (channel-get result-ch))])
      (for ([r results])
        (format "~a" (car r))
        (spell (cdr r))
        ;(newline)
        )
      (spell (apply + (map car results)))
      ;(newline)
      )))

(define n 120000)
(define (main)
  (begin (go n '(blue red yellow))
         (go n '(blue red yellow red yellow blue red yellow red blue))))
(time (begin (main) (void)))

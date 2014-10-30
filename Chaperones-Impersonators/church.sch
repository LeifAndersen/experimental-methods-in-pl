(import (rnrs) (larceny benchmarking))

(define (n->f n)
  (cond
    [(zero? n) (lambda (f) (lambda (x) x))]
    [else 
     (let ([n-1 (n->f (- n 1))])
       (lambda (f) 
         (let ([fn-1 (n-1 f)])
           (lambda (x) (f (fn-1 x))))))]))

(define (c:* n1)
  (lambda (n2) 
     (lambda (f) 
        (n1 (n2 f)))))

(define (f->n c)
  ((c (lambda (x) (+ x 1))) 0))

(define (c:zero? c)
  ((c (lambda (x) #f)) #t))

;; taken from Wikipedia (but lifted out
;; the definition of 'X')
(define (c:sub1 n)
  (lambda (f) 
    (let ([X (lambda (g) (lambda (h) (h (g f))))])
      (lambda (x) 
        (((n X) 
          (lambda (u) x)) 
         (lambda (u) u))))))

(define (c:! n)
  (cond
    [(c:zero? n) (lambda (f) f)]
    [else ((c:* n) (c:! (c:sub1 n)))]))

(time (f->n (c:! (n->f 9))))


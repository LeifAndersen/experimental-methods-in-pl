;; This is a copy of "church-wrap.sch", but without the first line

(define (-> a b) (lambda (f)
                   (and (procedure? f)
                        (lambda (x)
                          (b (f (a x)))))))
(define (exact-nonnegative-integer/c n)
  (and (exact? n)
       (integer? n)
       (>= n 0)
       n))
(define (boolean/c n)
  (and (boolean? n)
       n))
(define-syntax define/contract 
  (syntax-rules ()
    [(_ (f x) c b)
     (define f (c (lambda (x) b)))]))
(define any (lambda (x) x))
(define any/c (lambda (x) x))

(define church/c (-> (-> any/c any) (-> any/c any)))

(define/contract (n->f n)
  (-> exact-nonnegative-integer/c church/c)
  (cond
    [(zero? n) (lambda (f) (lambda (x) x))]
    [else 
     (let ([n-1 (n->f (- n 1))])
       (lambda (f) 
         (let ([fn-1 (n-1 f)])
           (lambda (x) (f (fn-1 x))))))]))

(define/contract (c:* n1)
  (-> church/c (-> church/c church/c))
  (lambda (n2) 
     (lambda (f) 
        (n1 (n2 f)))))

(define/contract (f->n c)
  (-> church/c exact-nonnegative-integer/c)
  ((c (lambda (x) (+ x 1))) 0))

(define/contract (c:zero? c)
  (-> church/c boolean/c)
  ((c (lambda (x) #f)) #t))

;; taken from Wikipedia (but lifted out
;; the definition of 'X')
(define/contract (c:sub1 n)
  (-> church/c church/c)
  (lambda (f) 
    (let ([X (lambda (g) (lambda (h) (h (g f))))])
      (lambda (x) 
        (((n X) 
          (lambda (u) x)) 
         (lambda (u) u))))))

(define/contract (c:! n)
  (-> church/c church/c )
  (cond
    [(c:zero? n) (lambda (f) f)]
    [else ((c:* n) (c:! (c:sub1 n)))]))

(time (f->n (c:! (n->f 9))))


#lang racket

(define-syntax-rule (check e) e)
#;
(define-syntax-rule (check e)
  (let ([v e])
    (unless (integer? v) (error "bad"))
    v))


(define e (lambda (x) x))
#;
(define e (lambda (x) (string->number (number->string x))))


(define N 10000000)

'direct
(time
 (for ([i (in-range N)])
   (e i)))

(define f #f)
(set! f e)

'indirect
(time
 (for ([i (in-range N)])
   (f i)))

(define g #f)
(set! g (lambda (x) (check (f (check x)))))

'wrapped
(time
 (for ([i (in-range N)])
   (g i)))

(define make-g1 #f)
(set! make-g1 (lambda (pre post)
                (lambda (x) (post (f (pre x))))))
(define g1 (make-g1 (lambda (x) x) (lambda (x) x)))

'wrapped+check
(time
 (for ([i (in-range N)])
   (g1 i)))

(define g2 #f)
(set! g2 (lambda (x) (cons (f (check x)) (lambda (y) (check y)))))

'wrapped+return
(time
 (for ([i (in-range N)])
   (let ([p (g2 i)])
     ((cdr p) (car p)))))

(define h0 (impersonate-procedure f (lambda (x) (check x))))

'impersonate
(time
 (for ([i (in-range N)])
   (h0 i)))

(define h (impersonate-procedure f
                                 (lambda (x)
                                   (values (lambda (y) (check y)) (check x)))))

'impersonate+return
(time
 (for ([i (in-range N)])
   (h i)))

(define j0 (chaperone-procedure f (lambda (x) (check x))))

'chaperone
(time
 (for ([i (in-range N)])
   (j0 i)))

(define j (chaperone-procedure f
                               (lambda (x)
                                 (values (lambda (y) (check y)) (check x)))))

'chaperone+return
(time
 (for ([i (in-range N)])
   (j i)))

(define k (chaperone-procedure f
                               (lambda (x)
                                 (values (lambda (y) (check y)) (check x)))
                               impersonator-prop:application-mark
                               '(1 . 2)))

'chaperone+mark
(time
 (for ([i (in-range N)])
   (k i)))

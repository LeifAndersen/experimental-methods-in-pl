;; This file is a copy of "proc-bm.sch", but with
;; the first line removed!

(define-syntax check
  (syntax-rules ()
    [(check e) e]))

(define-syntax for
  (syntax-rules ()
    [(for ([i (in-range N)]) e)
     (let loop ([i N]) 
       (if (zero? i)
           'done
           (begin
             e
             (loop (- i 1)))))]))

(define e (lambda (x) x))

(define (show n) (display n) (newline))

(define N 10000000)

(show 'direct)
(time
 (for ([i (in-range N)])
   (e i)))

(define f #f)
(set! f e)

(show 'indirect)
(time
 (for ([i (in-range N)])
   (f i)))

(define g #f)
(set! g (lambda (x) (check (f (check x)))))

(show 'wrapped)
(time
 (for ([i (in-range N)])
   (g i)))

(define make-g1 #f)
(set! make-g1 (lambda (pre post)
                (lambda (x) (post (f (pre x))))))
(define g1 (make-g1 (lambda (x) x) (lambda (x) x)))

(show 'wrapped+check)
(time
 (for ([i (in-range N)])
   (g1 i)))

(define g2 #f)
(set! g2 (lambda (x) (cons (f (check x)) (lambda (y) (check y)))))

(show 'wrapped+return)
(time
 (for ([i (in-range N)])
   (let ([p (g2 i)])
     ((cdr p) (car p)))))

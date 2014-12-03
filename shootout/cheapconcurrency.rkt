#lang racket/base
(require racket/cmdline
         racket/contract)

(define nat? exact-nonnegative-integer?)

(define/contract (generate receive-ch n)
  (-> (channel/c nat?) nat? (channel/c nat?))
  (if (zero? n)
      receive-ch
      (let ([ch (make-channel)])
        (thread (lambda ()
                  (let loop ()
                    (channel-put ch (add1 (channel-get receive-ch)))
                    (loop))))
        (generate ch (sub1 n)))))

(define (main n)
  (let* ([start-ch (make-channel)]
         [end-ch (generate start-ch 500)])
    (define/contract (loop n total)
      (-> exact-nonnegative-integer? exact-nonnegative-integer? string?)
      (if (zero? n)
          (format "~a\n" total)
          (begin
            (channel-put start-ch 0)
            (loop (sub1 n)
                  (+ total (channel-get end-ch))))))
    (loop n 0)))
(time (begin (main 2000) (void)))

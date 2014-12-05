#lang racket/base

(require racket/contract)

(define/contract (main argv)
  (-> (vectorof string?) string?)
  (let* ([n (string->number (vector-ref argv 0))]
         [hash1 (make-hash)]
         [hash2 (make-hash)]
         [zero (lambda () 0)])
    (define/contract (loop1 i)
      (-> natural-number/c void?)
      (unless (= i 10000)
        (hash-set! hash1 (string-append "foo_" (number->string i)) i)
        (loop1 (add1 i))))
    (loop1 0)
    (define/contract (loop2 i)
      (-> natural-number/c void?)
      (unless (= i n)
        (hash-for-each hash1 (lambda (key value)
                               (hash-set!
                                hash2
                                key
                                (+ (hash-ref hash2 key zero) value))))
        (loop2 (add1 i))))
    (loop2 0)
    (format "~s ~s ~s ~s\n"
            (hash-ref hash1 "foo_1")
            (hash-ref hash1 "foo_9999")
            (hash-ref hash2 "foo_1")
            (hash-ref hash2 "foo_9999"))))

(time (begin (main (vector "1000")) (void)))

#lang racket/base
(require racket/tcp
         racket/contract)

(define PORT 8887)
(define DATA "Hello there sailor\n")
(define n 10)

(define/contract (server)
  (-> void?)
  (thread client)
  (let-values ([(in out) (tcp-accept (tcp-listen PORT 5 #t))]
               [(buffer) (make-string (string-length DATA))])
    (file-stream-buffer-mode out 'none)
    (define/contract (loop i bytes)
      (-> natural-number/c natural-number/c void?)
      (if (not (eof-object? i))
          (begin
            (display buffer out)
            (loop (read-string! buffer in)
                  (+ bytes (string-length buffer))))
          (void)))
    (loop (read-string! buffer in) 0)
          ))

(define/contract (client)
  (-> none/c)
  (let-values ([(in out) (tcp-connect "127.0.0.1" PORT)]
               [(buffer) (make-string (string-length DATA))])
    (file-stream-buffer-mode out 'none)
    (define/contract (loop n)
      (-> natural-number/c void?)
      (if (> n 0)
          (begin
            (display DATA out)
            (let ([i (read-string! buffer in)])
              (begin
                (if (equal? DATA buffer)
                    (loop (- n 1))
                    'error))))
          (close-output-port out)))
    (loop n)
          ))

(define/contract (main args)
  (-> (vectorof string?) none/c)
  (set! n
        (if (= (vector-length args) 0)
            1
            (string->number (vector-ref  args 0))))
  (server))

(time (begin (main (vector "200000")) (void)))

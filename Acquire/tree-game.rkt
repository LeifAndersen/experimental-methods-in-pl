#lang racket/gui

(provide main)

;; ---------------------------------------------------------------------------------------------------
;; IMPLEMENTATION

(require "admin.rkt"
         "state.rkt"
         "player-factory.rkt"
         "Lib/auxiliaries.rkt")

(module+ test (require rackunit))

(define (main n)
  (for ((i (in-range n)))
    (go (inf-loop-player 0))))

(define (go extra)
  (define p1 (random-players 5))
  (define p (cons extra p1))
  (define-values (two-status _score two-run) (run p 99 #:choice randomly-pick))
  (void)) ; (format `(,(length two-run) ,two-status)))

(define (run players turns# #:show (show values #;(show)) #:choice (choose-next-tile first))
  (define a (new administrator% (next-tile choose-next-tile)))
  (for ((p players)) (send p go a))
  (send a run turns# #:show show))

;; -> (Nat Board -> Void)
(define (show)
  (parameterize ((current-eventspace (make-eventspace)))
    (define frame  (new frame% [label "Acquire Game"][width 1000][height 1000]))
    (define paste  (new pasteboard%))
    (define canvas (new editor-canvas% [parent frame][editor paste]))
    (send frame show #t)
    (lambda (n state)
      (send paste begin-edit-sequence)
      (send paste select-all)
      (send paste clear)
      (send paste insert (state-draw state) 0 0)
      (send paste end-edit-sequence)
      (sleep 1))))

(module+ test
  (define-values (status _score0 test) (run (ordered-players 3) 4))
  (check-equal? (length test) 5)
 
  (define-values (one-status _score1 one-run) (run (ordered-players 6) 99))
  (check-equal? (length one-run) 25) ; 23
  (check-equal? one-status 'score)
  
  (define-values (two-status _score2 two-run) (run (random-players 6) 99 #:choice randomly-pick))
  (length two-run)
  two-status

)

(module+ test 
  (go (merge-bad-player))
  (go (keep-bad-player))
  (go (end-bad-player))
  (go (receive-bad-player))
  (go (inform-bad-player))
  (go (setup-bad-player))
  (go (inf-loop-player 1)))

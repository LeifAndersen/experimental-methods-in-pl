#lang racket/base

;; Nerf the RNG
(random-seed 9001)

(require "tree-game.rkt")

(time (begin (main 1) (void)))

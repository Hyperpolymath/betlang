#lang racket
(provide bet)

;; (bet A B C) randomly picks one of three values.
(define (bet a b c)
  (match (random 3)
    [0 a]
    [1 b]
    [_ c]))

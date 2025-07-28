#lang racket
(provide ternary-eval)

;; Abstract ternary conditional: cond → truth ∣ fallback
(define (ternary-eval cond truth fallback)
  (if cond truth fallback))

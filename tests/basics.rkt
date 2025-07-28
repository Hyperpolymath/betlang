#lang racket
(require rackunit)
(require \"../core/betlang.rkt\")

(module+ test
  ;; Ensure each outcome appears in 100 trials
  (define results (for/list ([i (in-range 100)]) (bet \"A\" \"B\" \"C\")))
  (for ([opt '(\"A\" \"B\" \"C\")])
    (check-true (member opt results))))

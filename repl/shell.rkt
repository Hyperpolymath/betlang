#lang racket
(require racket/readline racket/format)
(require "../core/betlang.rkt")
(define logfile \"../logs/session.log\")

(define (log-line txt)
  (with-output-to-file logfile #:exists 'append
    (lambda () (displayln txt))))

(displayln \"🎰 Welcome to betlang REPL\")
(displayln \"Type: (bet \\\"Win\\\" \\\"Retry\\\" \\\"Lose\\\")\")

(let loop ()
  (display \"betlang> \") (flush-output)
  (define expr (read))
  (unless (eof-object? expr)
    (define result (eval expr))
    (displayln result)
    (log-line (format \"INPUT: ~a | OUTPUT: ~a\" expr result))
    (loop)))

#lang racket

;
; Member function for a self-ordering, immutable list
;
; Returns a copy of lst with v moved to the head
;
(define (member v lst)
  (define (iter xs ys)
    (cond
      [(null? ys) #f]
      [(= (car ys) v) (cons (car ys) (-+ xs (cdr ys)))]
      [else (iter (cons (car ys) xs) (cdr ys))]))
  (iter '() lst))

;
; Reverse append
;
; Returns a list equivalent to the result of: (append (reverse xs) ys)
; But in O(length xs) rather than O(2 * length xs)
;
(define/match (-+ xs ys)
  [('() ys) ys]
  [(xs '()) (reverse xs)]
  [((list-rest x xs) ys) (-+ xs (cons x ys))])

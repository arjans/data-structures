#lang racket

(require racket/match)
(require pict)
(require pict/tree-layout)

(define (reduce x y z)
  (if (null? z)
      y
      (x (car z) (reduce x y (cdr z)))))

(define (red-black-insert val tree)
  (define (helper v t)
    (if (null? t)
        (list 'r '() v '())
        (match-let ([(list tc tl tv tr) t])
          (cond ((< v tv) (balance (list tc (helper v tl) tv tr)))
                ((> v tv) (balance (list tc tl tv (helper v tr))))
                (else t)))))
  (match-let ([(list c l v r) (helper val tree)])
    ; always color root node black
    (list 'b l v r)))

(define (balance t)
  (match t
    [(list _ (list 'r (list 'r a x b) y c) z d) (list 'r (list 'b a x b) y (list 'b c z d))]
    [(list _ a x (list 'r b y (list 'r c z d))) (list 'r (list 'b a x b) y (list 'b c z d))]
    [(list _ a x (list 'r (list 'r b y c) z d)) (list 'r (list 'b a x b) y (list 'b c z d))]
    [(list _ (list 'r a x (list 'r b y c)) z d) (list 'r (list 'b a x b) y (list 'b c z d))]
    [_ t]))

(define (display-tree t)
  (define (layout t)
    (match t
      ['() #f]
      [(list c l v r)
       (tree-layout
        #:pict (cc-superimpose (text (number->string v))
                               (circle 30 #:border-color (if (eq? c 'r) "red" "black")))
        (layout l)
        (layout r))]
      [_ 'error-in-display-tree]))
  (binary-tidier (layout t)))

#lang racket

(require racket/match)
(require pict)
(require pict/tree-layout)

(define (reduce x y z)
  (if (null? z)
      y
      (x (car z) (reduce x y (cdr z)))))

; Colors don't make as much sense when you add double-black and negative black.
; I'm using numbers here instead. Black is 1, red is 0, negative black is -1, double black is 2.
; The idea is to keep black height constant. Numbers make that relationship apparent.

(struct tree (color left value right))

(define (min t)
  (if (tree-left t)
      (min (tree-left t))
      (tree-value t)))

(define (rb-insert v t)
  ; helper function for recursion
  (define (helper x y)
    (if y
        (match-let ([(tree tc tl tv tr) y])
          (cond ((< x tv) (balance (tree tc (helper x tl) tv tr)))
                ((> x tv) (balance (tree tc tl tv (helper x tr))))
                (else y)))
        (tree 0 #f x #f)))
  ; call helper function, then re-color root node to black
  (match-let ([(tree _ x y z) (helper v t)])
    (tree 1 x y z)))

(define (rb-delete v t)
  (define (helper x y)
    (define (less-than-target? v)
      (< v x))
    (define (greater-than-target? v)
      (> v x))
    (match y
      ; value not found
      [#f #f]
      ; red leaf node
      [(tree 0 #f (== x) #f) #f]
      ; target node has only one branch
      [(or (tree c (tree _ bl bv br) (== x) #f) (tree c #f (== x) (tree _ bl bv br))) (tree c bl bv br)]
      ; target node has two branches
      [(tree c (? tree? l) (== x) (? tree? r)) (bubble (tree c l (min r) (helper (min r) r)))]
      ; leaf black child node
      [(tree c (tree 1 #f (== x) #f) v (tree _ rl rv rr)) (bubble (tree (+ 1 c) #f v (tree 0 rl rv rr)))]
      [(tree c (tree _ ll lv lr) v (tree 1 #f (== x) #f)) (bubble (tree (+ 1 c) (tree 0 ll lv lr) v #f))]
      ; node value is less than target value
      [(tree c l (? less-than-target? v) r) (bubble (tree c l v (helper x r)))]
      ; node value is greater than target value
      [(tree c l (? greater-than-target? v) r) (bubble (tree c (helper x l) v r))]
      ; this case covers root deletion
      [(tree _ #f (== x) #f) #f]
      [_ 'error-in-red-black-delete]))
  (match (helper v t)
    [(tree _ x y z) (tree 1 x y z)]
    [#f #f]))

(define (bubble t)
  (match t
    [(or (tree (or 1 0) (tree 2 ll lv lr) v (tree _ rl rv rr))
         (tree (or 1 0) (tree _ ll lv lr) v (tree 2 rl rv rr)))
     (balance (tree (+ 1 (tree-color t))
                    (tree (- (tree-color (tree-left t)) 1) ll lv lr)
                    v
                    (tree (- (tree-color (tree-right t)) 1) rl rv rr)))]
    [_ t]))

(define (balance t)
  (match t
    ; Match black or double-black with two red descendants
    [(or (tree (or 1 2) (tree 0 (tree 0 a x b) y c) z d)
         (tree (or 1 2) a x (tree 0 b y (tree 0 c z d)))
         (tree (or 1 2) a x (tree 0 (tree 0 b y c) z d))
         (tree (or 1 2) (tree 0 a x (tree 0 b y c)) z d))
     ; return:
     (tree (- (tree-color t) 1) (tree 1 a x b) y (tree 1 c z d))]
    
    ; Match a negative black child
    [(or (tree 2 (tree -1 (tree _ a w b) x (tree _ c y d)) z e)
         (tree 2 a w (tree -1 (tree _ b x c) y (tree _ d z e))))
     ; return:
     (tree 1 (tree 1 (tree 0 a w b) x c) y (tree 1 d z e))]
    
    ; Skip everything else
    [_ t]))

(define (display-tree t)
  (define (layout t)
    (match t
      [(tree c l v r)
       (tree-layout
        #:pict (cc-superimpose (text (number->string v))
                               (circle 30 #:border-color (match c [0 "red"] [1 "black"] [2 "blue"] [-1 "yellow"])))
        (layout l)
        (layout r))]
      [_ t]))
  (binary-tidier (layout t)))

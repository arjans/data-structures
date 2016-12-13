#lang racket

(require racket/match)
(require pict)
(require pict/tree-layout)

(define (reduce x y z)
  (if (null? z)
      y
      (x (car z) (reduce x y (cdr z)))))

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
        (tree 'r #f x #f)))
  ; call helper function, then re-color root node to black
  (match-let ([(tree _ x y z) (helper v t)])
    (tree 'b x y z)))

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
      [(tree 'r #f (== x) #f) #f]
      ; target node has only one branch
      [(or (tree c (tree _ bl bv br) (== x) #f) (tree c #f (== x) (tree _ bl bv br))) (tree c bl bv br)]
      ; target node has two branches
      [(tree c (? tree? l) (== x) (? tree? r)) (bubble (tree c l (min r) (helper (min r) r)))]
      ; leaf black child node
      [(tree c (tree 'b #f (== x) #f) v (tree _ rl rv rr)) (bubble (tree (inc-color c) #f v (tree 'r rl rv rr)))]
      [(tree c (tree _ ll lv lr) v (tree 'b #f (== x) #f)) (bubble (tree (inc-color c) (tree 'r ll lv lr) v #f))]
      ; node value is less than target value
      [(tree c l (? less-than-target? v) r) (bubble (tree c l v (helper x r)))]
      ; node value is greater than target value
      [(tree c l (? greater-than-target? v) r) (bubble (tree c (helper x l) v r))]
      ; this case covers root deletion
      [(tree _ #f (== x) #f) #f]
      [_ 'error-in-red-black-delete]))
  (match (helper v t)
    [(tree _ x y z) (tree 'b x y z)]
    [#f #f]))

(define (bubble t)
  (match t
    [(or (tree (or 'b 'r) (tree 'bb ll lv lr) v (tree _ rl rv rr))
         (tree (or 'b 'r) (tree _ ll lv lr) v (tree 'bb rl rv rr)))
     (balance (tree (inc-color (tree-color t))
                    (tree (dec-color (tree-color (tree-left t))) ll lv lr)
                    v
                    (tree (dec-color (tree-color (tree-right t))) rl rv rr)))]
    [_ t]))

(define (inc-color c)
  (match c
    ['b 'bb]
    ['r 'b]
    ['w 'r]
    [_ 'error]))

(define (dec-color c)
  (match c
    ['bb 'b]
    ['b 'r]
    ['r 'w]
    [_ 'error]))

(define (balance t)
  (match t
    [(or (tree 'bb (tree 'r (tree 'r a x b) y c) z d)
         (tree 'bb a x (tree 'r b y (tree 'r c z d)))
         (tree 'bb a x (tree 'r (tree 'r b y c) z d))
         (tree 'bb (tree 'r a x (tree 'r b y c)) z d))
     (tree 'b (tree 'b a x b) y (tree 'b c z d))]
    [(or (tree 'bb (tree 'w (tree _ a w b) x (tree _ c y d)) z e)
         (tree 'bb a w (tree 'w (tree _ b x c) y (tree _ d z e))))
     (tree 'b (tree 'b (tree 'r a w b) x c) y (tree 'b d z e))]
    [(or (tree _ (tree 'r (tree 'r a x b) y c) z d)
         (tree _ a x (tree 'r b y (tree 'r c z d)))
         (tree _ a x (tree 'r (tree 'r b y c) z d))
         (tree _ (tree 'r a x (tree 'r b y c)) z d))
     (tree 'r (tree 'b a x b) y (tree 'b c z d))]
    [_ t]))

(define (display-tree t)
  (define (layout t)
    (match t
      [#f #f]
      [(tree c l v r)
       (tree-layout
        #:pict (cc-superimpose (text (number->string v))
                               (circle 30 #:border-color (match c ['r "red"] ['b "black"] ['bb "blue"] ['w "yellow"])))
        (layout l)
        (layout r))]
      [_ 'error-in-display-tree]))
  (binary-tidier (layout t)))

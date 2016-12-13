#lang racket

(require racket/match)
(require pict)
(require pict/tree-layout)

(define (reduce x y z)
  (if (null? z)
      y
      (x (car z) (reduce x y (cdr z)))))

(define-match-expander
  <<
  (lambda (stx)
    (syntax-case stx ()
      [(_ val) #'(? (lambda (x) (< x val)))])))

(define-match-expander
  >>
  (lambda (stx)
    (syntax-case stx ()
      [(_ val) #'(? (lambda (x) (> x val)))])))

;(define-match-expander <<
;  (lambda (val)
;    (syntax-case val ()
;      [y #'(? (lambda (x) (< x val)) y)])))

; Colors don't make as much sense when you add double-black and negative black.
; I'm using numbers here instead. Black is 1, red is 0, negative black is -1, double black is 2.
; The idea is to keep black height constant. Numbers make that relationship apparent.

; Pattern matching means no type errors compared with nested conditionals.

(struct T (color left value right))

(define (min t)
  (if (T-left t)
      (min (T-left t))
      (T-value t)))

(define (rb-insert v t)
  ; helper function for recursion
  (define (helper x y)
    (if y
        (match-let ([(T tc tl tv tr) y])
          (cond ((< x tv) (balance (T tc (helper x tl) tv tr)))
                ((> x tv) (balance (T tc tl tv (helper x tr))))
                (else y)))
        (T 0 #f x #f)))
  ; call helper function, then re-color root node to black
  (match-let ([(T _ x y z) (helper v t)])
    (T 1 x y z)))

(define (rb-delete v t)
  (define (helper x y)
    (match y
      ; value not found
      [#f                                         #f]
      ; red leaf node
      [(T 0 #f (== x) #f)                         #f]
      ; target node has only one branch
      [(or (T c (T _ bl bv br) (== x) #f)
           (T c #f (== x) (T _ bl bv br)))        (T c bl bv br)]
      ; target node has two branches
      [(T c (? T? l) (== x) (? T? r))             (bubble (T c l (min r) (helper (min r) r)))]
      ; leaf black child node
      [(T c (T 1 #f (== x) #f) v (T _ rl rv rr))  (bubble (T (+ 1 c) #f v (T 0 rl rv rr)))]
      [(T c (T _ ll lv lr) v (T 1 #f (== x) #f))  (bubble (T (+ 1 c) (T 0 ll lv lr) v #f))]
      ; node value is less than target value
      [(T c l (<< x) r)                           (bubble (T c l (T-value t) (helper x r)))]
      ; node value is greater than target value
      [(T c l (>> x) r)                           (bubble (T c (helper x l) (T-value t) r))]
      ; this case covers root deletion
      [(T _ #f (== x) #f)                         #f]
      [_                                          'error-in-red-black-delete]))
  (match (helper v t)
    [(T _ x y z) (T 1 x y z)]
    [#f #f]))

(define (bubble t)
  (match t
    ; red or black parent with a double-black child
    [(or (T (or 1 0) (T 2 ll lv lr) v (T _ rl rv rr))
         (T (or 1 0) (T _ ll lv lr) v (T 2 rl rv rr)))
    ; return:
     (balance (T (+ 1 (T-color t))
                    (T (- (T-color (T-left t)) 1) ll lv lr)
                    v
                    (T (- (T-color (T-right t)) 1) rl rv rr)))]
    ; skip other subTs
    [_ t]))

(define (balance t)
  (match t
    ; Match black or double-black with two red descendants
    [(or (T (or 1 2) (T 0 (T 0 a x b) y c) z d)
         (T (or 1 2) a x (T 0 b y (T 0 c z d)))
         (T (or 1 2) a x (T 0 (T 0 b y c) z d))
         (T (or 1 2) (T 0 a x (T 0 b y c)) z d))
     ; return:
     (T (- (T-color t) 1) (T 1 a x b) y (T 1 c z d))]
    
    ; Match a negative black child
    [(or (T 2 (T -1 (T _ a w b) x (T _ c y d)) z e)
         (T 2 a w (T -1 (T _ b x c) y (T _ d z e))))
     ; return:
     (T 1 (T 1 (T 0 a w b) x c) y (T 1 d z e))]
    
    ; Skip everything else
    [_ t]))

(define (display-tree t)
  (define (layout t)
    (match t
      [(T c l v r)
       (tree-layout
        #:pict (cc-superimpose (text (number->string v))
                               (circle 30 #:border-color (match c [0 "red"] [1 "black"] [2 "blue"] [-1 "yellow"])))
        (layout l)
        (layout r))]
      [#f #f]))
  (binary-tidier (layout t)))

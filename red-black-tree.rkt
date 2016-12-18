#lang racket

(require racket/match)
(require pict)
(require pict/tree-layout)

;
; Helper functions for pattern matching
;

(define-match-expander
  <<
  (lambda (stx)
    (syntax-case stx ()
      [(_ val) #'(? (lambda (x) (< x val)))]
      [(_ val var) #'(? (lambda (x) (< x val)) var)])))

(define-match-expander
  >>
  (lambda (stx)
    (syntax-case stx ()
      [(_ val) #'(? (lambda (x) (> x val)))]
      [(_ val var) #'(? (lambda (x) (> x val)) var)])))

; Colors don't make as much sense when you add double-black and negative black.
; I'm using numbers here instead. Black is 1, red is 0, negative black is -1, double black is 2.
; The idea is to keep black height constant. Numbers make that relationship apparent.

; Pattern matching means no null errors compared with conditionals.

(struct T (color left value right))

(define (min t)
  (if (T-left t)
      (min (T-left t))
      (T-value t)))

(define (member? val tree)
  (match tree
    [(T _ l (>> val) _) (member? val l)]
    [(T _ _ (<< val) r) (member? val r)]
    [(T _ _ (== val) _) #t]
    [#f #f]
    [_ 'error]))

(define (rb-insert val tree)
  (define/match (helper y)
    [((T c l (>> val v) r)) (balance (T c (helper l) v r))]
    [((T c l (<< val v) r)) (balance (T c l v (helper r)))]
    [((T _ _ (== val) _))   y]
    [(#f)                   (T 0 #f val #f)])
  (match-let ([(T _ x y z) (helper tree)])
    (T 1 x y z)))

(define (rb-delete val tree)
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
      [(T c l (<< x v) r)                         (bubble (T c l v (helper x r)))]
      ; node value is greater than target value
      [(T c l (>> x v) r)                         (bubble (T c (helper x l) v r))]
      ; this case covers root deletion
      [(T _ #f (== x) #f)                         #f]
      [_                                          'error-in-red-black-delete]))
  (match (helper val tree)
    [(T _ x y z) (T 1 x y z)]
    [#f #f]))

(define/match (bubble t)
  ; red or black parent with a double-black child
  [((or (T (or 1 0) (T 2 ll lv lr) v (T _ rl rv rr))
        (T (or 1 0) (T _ ll lv lr) v (T 2 rl rv rr))))
   ; =>
   (balance (T (+ 1 (T-color t))
               (T (- (T-color (T-left t)) 1) ll lv lr)
               v
               (T (- (T-color (T-right t)) 1) rl rv rr)))]
  ; skip other subtrees
  [(_) t])

(define (balance t)
  (match t
    ; Match black or double-black with two red descendants
    [(or (T (or 1 2) (T 0 (T 0 a x b) y c) z d)
         (T (or 1 2) a x (T 0 b y (T 0 c z d)))
         (T (or 1 2) a x (T 0 (T 0 b y c) z d))
         (T (or 1 2) (T 0 a x (T 0 b y c)) z d))
     ; =>
     (T (- (T-color t) 1) (T 1 a x b) y (T 1 c z d))]
    
    ; Match a negative black child
    [(or (T 2 (T -1 (T _ a w b) x (T _ c y d)) z e)
         (T 2 a w (T -1 (T _ b x c) y (T _ d z e))))
     ; =>
     (T 1 (T 1 (T 0 a w b) x c) y (T 1 d z e))]
    
    ; Skip everything else
    [_ t]))

;
; Pretty printing a red-black tree
;

(define (display-tree t)
  (define (layout t)
    (match t
      [(T c l v r)
       (tree-layout
        #:pict
        (cc-superimpose (text (number->string v))
                        (circle 30
                                #:border-color
                                (match c [0 "red"] [1 "black"] [2 "blue"] [-1 "yellow"])))
        (layout l)
        (layout r))]
      [#f #f]))
  (binary-tidier (layout t)))

;
; Tree validity functions
;

(define/match (black-height tree)
  [(#f) 0]
  [((T c l _ _)) (+ c (black-height l))])

(define (valid? tree)
  (let ((height (black-height tree)))
    (define/match (recur h t)
      [((== height) #f)                         #t] ; true if h at leaf matches h at min leaf
      [(_ #f)                                   #f] ; false if h is greater or less
      [(_ (T (not (or 0 1)) _ _ _))             #f] ; false if not black or red
      [(_ (T 0 (T 0 _ _ _) _ _))                #f] ; false if red with red left child
      [(_ (T 0 _ _ (T 0 _ _ _)))                #f] ; false if red with red right child
      [(_ (T _ (T _ _ (>> (T-value t)) _) _ _)) #f] ; false if left child has greater value
      [(_ (T _ _ _ (T _ _ (<< (T-value t)) _))) #f] ; false if right child has lesser value
      [(_ (T c l _ r))                          (and (recur (+ c h) l)
                                                     (recur (+ c h) r))])
    (recur 0 tree)))

;
; Generating random trees for testing
;

(define (randomlist n mx)
  (for/list ((i n))
    (add1 (random mx))))

(define (random-rb-tree vals)
  (foldl rb-insert #f vals))

;
; Test!
;

(define (test-rb-trees tree-size num-trees)
  (define (recur n)
    (if (= n 0)
        #t
        (let* ((vals (randomlist tree-size (* tree-size 10)))
               (tree (random-rb-tree vals)))
          (if (and (valid? tree)
                   (andmap (lambda (v) (member? v tree)) vals)
                   (andmap (lambda (v) (not (member? v (rb-delete v tree)))) vals))
              (recur (- n 1))
              #f))))
  (recur num-trees))

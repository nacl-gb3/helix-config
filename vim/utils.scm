(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "helix/editor.scm")
(require "helix/misc.scm")

(require-builtin helix/core/text)

(define (get-document-as-slice)
  (let* ([focus (editor-focus)]
         [focus-doc-id (editor->doc-id focus)])
    (editor->text focus-doc-id)))

(define (rope-char-at rope pos)
  (if (and (>= pos 0) (< pos (rope-len-chars rope)))
      (rope-char-ref rope pos)
      #f))

(define (is-whitespace? ch)
  (and ch
       (or (char=? ch #\space)
           (char=? ch #\tab)
           (char=? ch #\newline)
           (char=? ch #\return))))

(define (is-alphabetic? ch)
  (and ch
       (or (and (char>=? ch #\a) (char<=? ch #\z))
           (and (char>=? ch #\A) (char<=? ch #\Z)))))

(define (is-numeric? ch)
  (and ch (char>=? ch #\0) (char<=? ch #\9)))

(define (is-word-char? ch)
  (and ch
       (or (is-alphabetic? ch)
           (is-numeric? ch)
           (char=? ch #\_))))

(define (is-punctuation? ch)
  (and ch
       (not (is-whitespace? ch))
       (not (is-word-char? ch))))

(define (is-bracket? ch)
  (and ch
       (or (char=? ch #\{) (char=? ch #\})
           (char=? ch #\() (char=? ch #\))
           (char=? ch #\[) (char=? ch #\])
           (char=? ch #\") (char=? ch #\")
           (char=? ch #\') (char=? ch #\')
           (char=? ch #\<) (char=? ch #\>)
           )))

(define (get-selection-range)
  ;; Try to get selection info from editor
  ;; This may need adjustment based on actual Steel API
  (let* ([focus (editor-focus)]
         [focus-doc-id (editor->doc-id focus)])
    ;; If there's an API like editor->selection-range, use it
    ;; For now, we'll use a workaround
    #f))

;; Helper to check if we have a real selection (more than 1 char)
(define (has-real-selection? start-pos)
  (define end-pos (cursor-position))
  ;; If cursor moved, we have a selection
  (not (= start-pos end-pos)))

(define (move-to-position target-pos)
  (define current-pos (cursor-position))
  (define distance (- target-pos current-pos))
  (cond
    [(> distance 0) (move-right-n distance)]
    [(< distance 0) (move-left-n (- distance))]))

(define (skip-whitespace-forward rope)
  (let ([ch (rope-char-at rope (cursor-position))])
    (when (is-whitespace? ch)
      (helix.static.move_char_right)
      (skip-whitespace-forward rope))))

(define (move-left-n n)
  (when (> n 0)
    (helix.static.move_char_left)
    (move-left-n (- n 1))))

(define (move-right-n n)
  (when (> n 0)
    (helix.static.move_char_right)
    (move-right-n (- n 1))))

(define (do-n-times n func)
  (if (= n 0)
      void
      (begin
        (func)
        (do-n-times (- n 1) func))))

(define (move-to-char target-ch search-forward?)
  (define rope (get-document-as-slice))
  (define start-pos (cursor-position))
  (define len (rope-len-chars rope))
  
  (if search-forward?
      ;; Search forward
      (let loop ([i 1])
        (define pos (+ start-pos i))
        (cond
          [(>= pos len) #f]
          [else
           (let ([ch (rope-char-at rope pos)])
             (cond
               [(not ch) #f]
               [(char=? ch #\newline) #f]  ; Stop at newline
               [(char=? ch target-ch)
                ;; Found it - move cursor there
                (move-right-n i)
                #t]
               [else (loop (+ i 1))]))]))
      ;; Search backward (not currently used)
      #f))

(provide
  get-document-as-slice
  rope-char-at
  is-whitespace?
  is-alphabetic?
  is-numeric?
  is-word-char?
  is-punctuation?
  skip-whitespace-forward
  move-left-n
  move-right-n
  do-n-times
  is-bracket?
  get-selection-range
  has-real-selection?
  move-to-position
  move-to-char
)

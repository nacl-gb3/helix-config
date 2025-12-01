(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "utils.scm")
(require "key-emulation.scm")
(require "helix/misc.scm")
(require "helix/components.scm")

(require-builtin steel/time)

(require-builtin helix/core/text)

;; l
(define (extend-char-right-same-line)
  (define pos (cursor-position))
  (define char (rope-char-ref (get-document-as-slice) (+ 1 pos)))
  (when char
    (unless (equal? #\newline char)
      (helix.static.extend_char_right))))

;; h
(define (extend-char-left-same-line)
  (define pos (cursor-position))
  (define char (rope-char-ref (get-document-as-slice) (- pos 1)))
  (when char
    (unless (equal? #\newline char)
      (helix.static.extend_char_left))))

(define (extend-line-up-impl)
  (define pos (cursor-position))
  (define doc (get-document-as-slice))
  (define char (rope-char-ref doc pos))
  (when char
    (when (char=? #\newline char)
      (define char-to-left (rope-char-ref doc (- pos 1)))
      (when char-to-left
        (unless (char=? #\newline char-to-left)
          (helix.static.extend_char_left))))))

;; k
(define (extend-line-up)
  (helix.static.extend_line_up)
  (extend-line-up-impl))

(define (extend-line-down-impl)
  (define pos (cursor-position))
  (define doc (get-document-as-slice))
  (define char (rope-char-ref doc pos))
  (when char
    (when (char=? #\newline char)
      (define char-to-left (rope-char-ref doc (- pos 1)))
      (when char-to-left
        (unless (char=? #\newline char-to-left)
          (helix.static.extend_char_left))))))

;; j
(define (extend-line-down)
  (helix.static.extend_line_down)
  (extend-line-down-impl))

(define (select-around-impl key)
  (helix.static.select_textobject_around)
  (trigger-on-key-callback key))

(define (select-inner-impl key)
  (helix.static.select_textobject_inner)
  (trigger-on-key-callback key))

;; vaw
(define (select-around-word)
  (select-around-impl w-key))

;; viw
(define (select-inner-word)
  (select-inner-impl w-key))

;; vap
(define (select-around-paragraph)
  (select-around-impl p-key))

;; vip
(define (select-inner-paragraph)
  (select-inner-impl p-key))

;; vaf
(define (select-around-function)
  (select-around-impl f-key))

;; vif
(define (select-inner-function)
  (select-inner-impl f-key))

;; vac
(define (select-around-comment)
  (select-around-impl c-key))

;; vic
(define (select-inner-comment)
  (select-inner-impl c-key))

;; vae
(define (select-around-data-structure)
  (select-around-impl e-key))

;; vie
(define (select-inner-data-structure)
  (select-inner-impl e-key))

;; vax
(define (select-around-html-tag)
  (select-around-impl x-key))

;; vix
(define (select-inner-html-tag)
  (select-inner-impl x-key))

;; vit
(define (select-around-type-definition)
  (select-around-impl t-key))

;; vit
(define (select-inner-type-definition)
  (select-inner-impl t-key))

;; vaT
(define (select-around-test)
  (select-around-impl T-key))

;; viT
(define (select-inner-test)
  (select-inner-impl T-key))

;; TODO: broken - needs more work
;; vi{
;; vi[
;; vi(
;; vi"
;; vi'
;; vi<
(define (select-inner-bracket bracket-ch)
  (define rope (get-document-as-slice))
  (define start-pos (cursor-position))
  
  ;; Try to select inside current bracket pair
  (helix.static.select_textobject_inner)
  (trigger-on-key-callback (string->key-event 
                            (string (if (char=? bracket-ch #\{) #\{
                                     (if (char=? bracket-ch #\() #\(
                                         #\[)))))
  
  ;; Check if cursor moved (for inner, cursor always moves if selection succeeds)
  (when (not (has-real-selection? start-pos))
    ;; No selection made - search forward for the bracket
    (when (move-to-char bracket-ch #t)
      ;; Try the textobject again
      (helix.static.select_textobject_inner)
      (trigger-on-key-callback (string->key-event 
                                (string (if (char=? bracket-ch #\{) #\{
                                         (if (char=? bracket-ch #\() #\(
                                             #\[))))))))

;; Select around bracket - enhanced with forward search
;; Around is trickier because cursor might not move if we're on the opening bracket
;; TODO: broken - needs more work
;; va{
;; va[
;; va(
;; va"
;; va'
;; va<
(define (select-around-bracket bracket-ch)
  (define rope (get-document-as-slice))
  (define start-pos (cursor-position))
  (define start-char (rope-char-at rope start-pos))
  
  ;; Try to select around current bracket pair
  (helix.static.select_textobject_around)
  (trigger-on-key-callback (string->key-event 
                            (string (if (char=? bracket-ch #\{) #\{
                                     (if (char=? bracket-ch #\() #\(
                                         #\[)))))
  
  (define end-pos (cursor-position))
  
  ;; For around, we need to check:
  ;; 1. Did cursor move? If yes, we have a selection
  ;; 2. If cursor didn't move, are we on the opening bracket? If yes, we might still have a selection
  ;; 3. Otherwise, no selection - search forward
  
  (define cursor-moved (not (= start-pos end-pos)))
  (define on-target-bracket (and start-char (char=? start-char bracket-ch)))
  
  ;; If cursor didn't move AND we're not on the target bracket, search forward
  (when (and (not cursor-moved) (not on-target-bracket))
    (when (move-to-char bracket-ch #t)
      (helix.static.select_textobject_around)
      (trigger-on-key-callback (string->key-event 
                                (string (if (char=? bracket-ch #\{) #\{
                                         (if (char=? bracket-ch #\() #\(
                                             #\[))))))))

;; Public API functions
(define (select-inner-curly)
  (select-inner-bracket #\{))

(define (select-around-curly)
  (select-around-bracket #\{))

(define (select-inner-paren)
  (select-inner-bracket #\())

(define (select-around-paren)
  (select-around-bracket #\())

(define (select-inner-square)
  (select-inner-bracket #\[))

(define (select-around-square)
  (select-around-bracket #\[))

(define (select-inner-double-quote)
  (select-inner-bracket #\"))

(define (select-around-double-quote)
  (select-around-bracket #\"))

(define (select-inner-single-quote)
  (select-inner-bracket #\'))

(define (select-around-single-quote)
  (select-around-bracket #\'))

(define (select-inner-arrow)
  (select-inner-bracket #\<))

(define (select-around-arrow)
  (select-around-bracket #\<))

(provide 
  extend-char-right-same-line
  extend-char-left-same-line
  extend-line-up
  extend-line-down
  select-around-word
  select-inner-word
  select-around-paragraph
  select-inner-paragraph
  select-around-function
  select-inner-function
  select-around-comment
  select-inner-comment
  select-around-data-structure
  select-inner-data-structure
  select-around-html-tag
  select-inner-html-tag
  select-around-type-definition
  select-inner-type-definition
  select-around-test
  select-inner-test
  select-inner-curly
  select-around-curly
  select-inner-paren
  select-around-paren
  select-inner-square
  select-around-square
  select-inner-double-quote
  select-around-double-quote
  select-inner-single-quote
  select-around-single-quote
  select-inner-arrow
  select-around-arrow
)

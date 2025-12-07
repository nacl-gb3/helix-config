(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "helix/editor.scm")
(require "helix/misc.scm")

(require-builtin helix/core/text)

(require "utils.scm")
(require "visual-motions.scm")

;; dd
(define (evil-delete-line)
  (helix.static.extend_to_line_bounds)
  (helix.static.delete_selection))

;; TODO: broken - cuts off too much text in certain scenarios
;; dw
(define (evil-delete-word)
  (define pos (cursor-position))
  (helix.static.move_next_word_end)
  (define new-pos (cursor-position))
  (when (> (- new-pos pos) 1)
    (helix.static.extend_char_right))
  (helix.static.delete_selection))

;; TODO: broken - cuts off too much text in certain scenarios
;; dW
(define (evil-delete-long-word)
  (define pos (cursor-position))
  (helix.static.extend_next_long_word_end)
  (define new-pos (cursor-position))
  (when (> (- new-pos pos) 1)
    (helix.static.extend_char_right))
  (helix.static.delete_selection))

;; db
(define (evil-delete-prev-word)
  (define pos (cursor-position))
  (helix.static.extend_prev_word_start)
  (define new-pos (cursor-position))
  (when (> (- new-pos pos) 1)
    (helix.static.extend_char_right))
  (helix.static.delete_selection))

;; dB
(define (evil-delete-prev-long-word)
  (define pos (cursor-position))
  (helix.static.extend_prev_long_word_start)
  (define new-pos (cursor-position))
  (when (> (- new-pos pos) 1)
    (helix.static.extend_char_right))
  (helix.static.delete_selection))

(define (delete-impl func)
  (func)
  (helix.static.delete_selection))

;; de
(define (evil-delete-word-end)
  (delete-impl helix.static.extend_next_word_end))

;; dE
(define (evil-delete-long-word-end)
  (delete-impl helix.static.extend_next_long_word_end))

;; daw
(define (evil-delete-around-word)
  (delete-impl select-around-word))

;; diw
(define (evil-delete-inner-word)
  (delete-impl select-inner-word))

;; daW
;; (define (evil-delete-around-long-word)
;;   (select-around-word)
;;   (helix.static.delete_selection))

;; diW
;; (define (evil-delete-inner-long-word)
;;   (select-inner-word)
;;   (helix.static.delete_selection))

;; dap
(define (evil-delete-around-paragraph)
  (delete-impl select-around-paragraph))

;; dip
(define (evil-delete-inner-paragraph)
  (delete-impl select-inner-paragraph))

;; daf
(define (evil-delete-around-function)
  (delete-impl select-around-function))

;; dif
(define (evil-delete-inner-function)
  (delete-impl select-inner-function))

;; dac
(define (evil-delete-around-comment)
  (delete-impl select-around-comment))

;; dic
(define (evil-delete-inner-comment)
  (delete-impl select-inner-comment))

;; dae
(define (evil-delete-around-data-structure)
  (delete-impl select-around-data-structure))

;; die
(define (evil-delete-inner-data-structure)
  (delete-impl select-inner-data-structure))

;; dax
(define (evil-delete-around-html-tag)
  (delete-impl select-around-html-tag))

;; dix
(define (evil-delete-inner-html-tag)
  (delete-impl select-inner-html-tag))

;; dat
(define (evil-delete-around-type-definition)
  (delete-impl select-around-type-definition))

;; dit
(define (evil-delete-inner-type-definition)
  (delete-impl select-inner-type-definition))

;; daT
(define (evil-delete-around-test)
  (delete-impl select-around-test))

;; diT
(define (evil-delete-inner-test)
  (delete-impl select-inner-test))

;; da{
(define (evil-delete-around-curly)
  (delete-impl select-around-curly))

;; di{
(define (evil-delete-inner-curly)
  (delete-impl select-inner-curly))

;; da[
(define (evil-delete-around-square)
  (delete-impl select-around-square))

;; di[
(define (evil-delete-inner-square)
  (delete-impl select-inner-square))

;; di(
(define (evil-delete-inner-paren)
  (delete-impl select-inner-paren))

;; da(
(define (evil-delete-around-paren)
  (delete-impl select-around-paren))

;; da"
(define (evil-delete-around-double-quote)
  (delete-impl select-around-double-quote))

;; di"
(define (evil-delete-inner-double-quote)
  (delete-impl select-inner-double-quote))

;; da'
(define (evil-delete-around-single-quote)
  (delete-impl select-around-single-quote))

;; di'
(define (evil-delete-inner-single-quote)
  (delete-impl select-inner-single-quote))

;; da<
(define (evil-delete-around-arrow)
  (delete-impl select-around-arrow))

;; di<
(define (evil-delete-inner-arrow)
  (delete-impl select-inner-arrow))

(provide
  evil-delete-line
  evil-delete-word
  evil-delete-long-word
  evil-delete-word-end
  evil-delete-long-word-end
  evil-delete-around-word
  evil-delete-inner-word
  evil-delete-around-paragraph
  evil-delete-inner-paragraph
  evil-delete-prev-word
  evil-delete-prev-long-word
  evil-delete-around-function
  evil-delete-inner-function
  evil-delete-around-comment
  evil-delete-inner-comment
  evil-delete-around-data-structure
  evil-delete-inner-data-structure
  evil-delete-around-html-tag
  evil-delete-inner-html-tag
  evil-delete-around-type-definition
  evil-delete-inner-type-definition
  evil-delete-around-test
  evil-delete-inner-test
  evil-delete-around-curly
  evil-delete-inner-curly
  evil-delete-around-square
  evil-delete-inner-square
  evil-delete-inner-paren
  evil-delete-around-paren
  evil-delete-around-double-quote
  evil-delete-inner-double-quote
  evil-delete-around-single-quote
  evil-delete-inner-single-quote
  evil-delete-around-arrow
  evil-delete-inner-arrow
)

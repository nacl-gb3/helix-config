(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "helix/configuration.scm")
(require "helix/keymaps.scm")
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/ext.scm")
(require "helix/components.scm")

(require-builtin steel/time)

(require-builtin helix/core/text)

(provide move-char-right-same-line
         move-char-left-same-line
         move-line-up
         move-line-down
         evil-goto-line-or-last
         evil-find-next-char
         evil-find-prev-char
         evil-find-till-char
         evil-till-prev-char
         evil-append-mode
         evil-next-word-start
         evil-next-word-end
         evil-delete-line
         evil-delete-word
         evil-change-line
         evil-yank-line
         yank-around-word
         yank-inner-word
         evil-prev-word-start
         evil-prev-long-word-start
         evil-next-long-word-end
         evil-next-long-word-start
         extend-char-left-same-line
         extend-char-right-same-line
         extend-line-down
         extend-line-up
         yank-word
         yank-long-word
         yank-prev-word
         yank-prev-long-word
         yank-line-start
         yank-line-end
         yank-line-start-non-whitespace
         )

(define vim-keybindings
  (keymap (normal (l ":move-char-right-same-line")
                  (h ":move-char-left-same-line")
                  (k ":move-line-up")
                  (j ":move-line-down")
                  (f ":evil-find-next-char")
                  (F ":evil-find-prev-char")
                  (t ":evil-find-till-char")
                  (T ":evil-till-prev-char")
                  (a ":evil-append-mode")
                  (w ":evil-next-word-start")
                  (e ":evil-next-word-end")
                  (G ":evil-goto-line-or-last")
                  (A-d "no_op")
                  (A-c "no_op")
                  ;; Selecting the whole file
                  (% "match_brackets")
                  (X "no_op")
                  (A-x "no_op")
                  (p "paste_after")
                  (P "paste_before")
                  ;; TODO: More delete things
                  (d (d ":evil-delete-line") (w ":evil-delete-word"))
                  ;; TODO: More change things
                  (c (c ":evil-change-line"))
                  (x "delete_selection_noyank")
                  ;; TODO: More yank things
                  (y (y ":evil-yank-line") 
                     ;; TODO: around/inner long word
                     ;; TODO: paragraph, function, comment, test, html tag, etc.
                     (a (w ":yank-around-word")) 
                     (i (w ":yank-inner-word"))
                     (w ":yank-word")
                     (W ":yank-long-word")
                     (e ":yank-word")
                     (E ":yank-long-word")
                     (b ":yank-prev-word")
                     (B ":yank-prev-long-word")
                     ($ ":yank-line-end")
                     ("0" ":yank-line-start")
                     (^ ":yank-line-start-non-whitespace")
                  )
                  (b ":evil-prev-word-start")
                  (B ":evil-prev-long-word-start")
                  (E ":evil-next-long-word-end")
                  (W ":evil-next-long-word-start")
                  ("0" "goto_line_start")
                  ($ "goto_line_end")
                  (^ "goto_first_nonwhitespace")
                  (del "delete_selection"))
          ;; Select bindings
          ;; TODO: Rename this to VIS
          (select (a "select_textobject_around")
                  (i "select_textobject_inner")
                  (h ":extend-char-left-same-line")
                  (l ":extend-char-right-same-line")
                  (j ":extend-line-down")
                  (k ":extend-line-up"))
          (insert (C-d "unindent") (C-t "indent"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; HELPER FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide set-vim-keybindings!)
(define (set-vim-keybindings!)
  (add-global-keybinding vim-keybindings))

(define (get-document-as-slice)
  (let* ([focus (editor-focus)]
         [focus-doc-id (editor->doc-id focus)])
    (editor->text focus-doc-id)))

;; (define (cursor-position)
;;   (let* ([focus (editor-focus)]
;;          [focus-doc-id (editor->doc-id focus)])
;;     (editor->get-cursor focus-doc-id)))

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; VIM EMULATION FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (evil-goto-line-or-last)
  (define rope (get-document-as-slice))
  (define start-pos (cursor-position))
  
  (helix.static.goto_line)
  
  (define end-pos (cursor-position))
  
  ;; If we didn't move, no count was provided - go to last line
  (when (= start-pos end-pos)
    (helix.static.goto_last_line)))

(define (evil-append-mode)
  ;; Move to insert mode
  (helix.static.insert_mode)
  (helix.static.collapse_selection)
  (helix.static.move_char_right))

(define (move-char-right-same-line)
  (define pos (cursor-position))
  (define char (rope-char-ref (get-document-as-slice) (+ 1 pos)))
  (when char
    (unless (equal? #\newline char)
      (helix.static.move_char_right))))

(define (extend-char-right-same-line)
  (define pos (cursor-position))
  (define char (rope-char-ref (get-document-as-slice) (+ 1 pos)))
  (when char
    (unless (equal? #\newline char)
      (helix.static.extend_char_right))))

(define (move-char-left-same-line)
  (define pos (cursor-position))
  (define char (rope-char-ref (get-document-as-slice) (- pos 1)))
  (when char
    (unless (equal? #\newline char)
      (helix.static.move_char_left))))

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

(define (extend-line-up)
  (helix.static.extend_line_up)
  (extend-line-up-impl))

(define (move-line-up-impl)
  (define pos (cursor-position))
  (define doc (get-document-as-slice))
  (define char (rope-char-ref doc pos))
  (when char
    (when (char=? #\newline char)
      (define char-to-left (rope-char-ref doc (- pos 1)))
      (when char-to-left
        (unless (char=? #\newline char-to-left)
          (helix.static.move_char_left))))))

(define (move-line-up)
  (helix.static.move_line_up)
  (move-line-up-impl))

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

(define (extend-line-down)
  (helix.static.extend_line_down)
  (extend-line-down-impl))

(define (move-line-down-impl)
  (define pos (cursor-position))
  (define doc (get-document-as-slice))
  (define char (rope-char-ref doc pos))
  (when char
    (when (char=? #\newline char)
      (define char-to-left (rope-char-ref doc (- pos 1)))
      (when char-to-left
        (unless (char=? #\newline char-to-left)
          (helix.static.move_char_left))))))

(define (move-line-down)
  (helix.static.move_line_down)
  (move-line-down-impl))

(define (evil-find-next-char)
  (define (loop i next-char)
    (define pos (cursor-position))
    (define doc (get-document-as-slice))
    (define char (rope-char-ref doc (+ i pos)))
    (cond
      [(equal? char #\newline) void]
      ;; Move right n times
      [(equal? char next-char) (do-n-times i helix.static.move_char_right)]
      [else (loop (+ i 1) next-char)]))

  (on-key-callback (lambda (key-event)
                     (define char (on-key-event-char key-event))
                     (when char
                       (loop 1 char)))))

(define (evil-find-prev-char)
  (define (loop i next-char)
    (define pos (cursor-position))
    (define doc (get-document-as-slice))
    (define char (rope-char-ref doc (- pos i)))
    (cond
      [(equal? char #\newline) void]
      ;; Move right n times
      [(equal? char next-char) (do-n-times i helix.static.move_char_left)]
      [else (loop (+ i 1) next-char)]))

  (on-key-callback (lambda (key-event)
                     (define char (on-key-event-char key-event))
                     (when char
                       (loop 1 char)))))

(define (evil-find-till-char)
  (define (loop i next-char)
    (define pos (cursor-position))
    (define doc (get-document-as-slice))
    (define char (rope-char-ref doc (+ i pos)))
    (cond
      [(equal? char #\newline) void]
      ;; Move right n times
      [(equal? char next-char)
       (do-n-times i helix.static.move_char_right)
       (helix.static.move_char_left)]
      [else (loop (+ i 1) next-char)]))

  (on-key-callback (lambda (key-event)
                     (define char (on-key-event-char key-event))
                     (when char
                       (loop 0 char)))))

(define (evil-till-prev-char)
  (define (loop i next-char)
    (define pos (cursor-position))
    (define doc (get-document-as-slice))
    (define char (rope-char-ref doc (- pos i)))
    (cond
      [(equal? char #\newline) void]
      ;; Move right n times
      [(equal? char next-char)
       (do-n-times i helix.static.move_char_left)
       (helix.static.move_char_right)]
      [else (loop (+ i 1) next-char)]))

  (on-key-callback (lambda (key-event)
                     (define char (on-key-event-char key-event))
                     (when char
                       (loop 0 char)))))

;; TODO:
;; line wise vs character wise visual mode

(define (evil-delete-line)
  (helix.static.extend_to_line_bounds)
  (helix.static.delete_selection))

(define (evil-change-line)
  (evil-delete-line)
  (helix.static.move_line_up)
  (helix.static.open_below)
  (helix.static.goto_line_start))

(define (evil-delete-word)
  (define pos (cursor-position))
  (helix.static.extend_next_word_start)
  (define new-pos (cursor-position))
  (when (> (- new-pos pos) 1)
    (helix.static.extend_char_right))
  (helix.static.delete_selection))

;; TODO: Move the cursor to the next word.
;; If we've moved only one, don't move back one
;; Otherwise, move back one character.
(define (evil-next-word-start)
  (define rope (get-document-as-slice))
  (define start-pos (cursor-position))
  (define len (rope-len-chars rope))
  
  (define cur-char (rope-char-at rope start-pos))
  (define on-whitespace (is-whitespace? cur-char))
  (define on-word (is-word-char? cur-char))
  (define on-punct (is-punctuation? cur-char))
  
  (define (skip-whitespace pos)
    (let loop ([p pos])
      (let ([ch (rope-char-at rope p)])
        (cond
          [(>= p len) len]
          [(is-whitespace? ch) (loop (+ p 1))]
          [else p]))))
  
  (define (find-next-word-start pos)
    (cond
      [(>= pos len) len]
      
      ;; On whitespace: skip to first non-whitespace
      [on-whitespace
       (skip-whitespace pos)]
      
      ;; On word char: skip word chars, then skip whitespace
      [on-word
       (let* ([after-word (let loop ([p pos])
                            (let ([ch (rope-char-at rope p)])
                              (cond
                                [(>= p len) len]
                                [(is-word-char? ch) (loop (+ p 1))]
                                [else p])))]
              [after-space (skip-whitespace after-word)])
         after-space)]
      
      ;; On punctuation: skip punctuation, then skip whitespace
      [on-punct
       (let* ([after-punct (let loop ([p pos])
                             (let ([ch (rope-char-at rope p)])
                               (cond
                                 [(>= p len) len]
                                 [(is-punctuation? ch) (loop (+ p 1))]
                                 [else p])))]
              [after-space (skip-whitespace after-punct)])
         after-space)]
      
      [else pos]))
  
  (define target-pos (find-next-word-start start-pos))
  (when (> target-pos start-pos)
    (move-right-n (- target-pos start-pos))))

(define (evil-next-word-end)
  (helix.static.move_next_word_end)
  (helix.static.collapse_selection))

(define (evil-prev-word-start)
  (helix.static.move_prev_word_start)
  (helix.static.collapse_selection)
  (define pos (cursor-position))
  (define doc (get-document-as-slice))
  (define cur-char (rope-char-ref doc pos))
  (when (and cur-char (char-whitespace? cur-char))
    (evil-prev-word-start)))

(define (evil-prev-long-word-start)
  (helix.static.move_prev_long_word_start)
  (helix.static.collapse_selection)
  (define pos (cursor-position))
  (define doc (get-document-as-slice))
  (define cur-char (rope-char-ref doc pos))
  (when (and cur-char (char-whitespace? cur-char))
    (evil-prev-long-word-start)))

(define (evil-next-long-word-start)
  (define rope (get-document-as-slice))
  (define start-pos (cursor-position))
  (define len (rope-len-chars rope))
  
  (define cur-char (rope-char-at rope start-pos))
  (define on-whitespace (is-whitespace? cur-char))
  
  (define (skip-whitespace pos)
    (let loop ([p pos])
      (let ([ch (rope-char-at rope p)])
        (cond
          [(>= p len) len]
          ;; Stop if we hit a newline (empty line boundary)
          [(and (is-whitespace? ch) (not (char=? ch #\newline)))
           (loop (+ p 1))]
          [(char=? ch #\newline)
           ;; Move past the newline, but stop if next line is empty or has content
           (let ([next-pos (+ p 1)])
             (if (>= next-pos len)
                 len
                 (let ([next-ch (rope-char-at rope next-pos)])
                   (if (char=? next-ch #\newline)
                       ;; Empty line - stop here
                       next-pos
                       ;; Continue skipping whitespace on this line
                       (if (and next-ch (is-whitespace? next-ch) (not (char=? next-ch #\newline)))
                           (loop next-pos)
                           next-pos)))))]
          [else p]))))
  
  (define (skip-non-whitespace pos)
    (let loop ([p pos])
      (let ([ch (rope-char-at rope p)])
        (cond
          [(>= p len) len]
          [(is-whitespace? ch) p]
          [else (loop (+ p 1))]))))
  
  (define (find-next-word-start pos)
    (cond
      [(>= pos len) len]
      
      ;; On whitespace: skip to first non-whitespace
      [on-whitespace
       (skip-whitespace pos)]
      
      ;; On non-whitespace: skip to end, then skip whitespace
      [else
       (let* ([after-word (skip-non-whitespace pos)]
              [after-space (skip-whitespace after-word)])
         after-space)]))
  
  (define target-pos (find-next-word-start start-pos))
  (when (> target-pos start-pos)
    (move-right-n (- target-pos start-pos))))

(define (evil-next-long-word-end)
  (helix.static.move_next_long_word_end)
  (helix.static.collapse_selection))

(define (yank-current-line)
  (helix.static.extend_to_line_bounds)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.normal_mode)
  (helix.static.collapse_selection))

(define w-key (string->key-event "w"))
(define (select-around-word)
  (helix.static.select_textobject_around)
  (trigger-on-key-callback w-key))

(define (select-inner-word)
  (helix.static.select_textobject_inner)
  (trigger-on-key-callback w-key))

;; Emulate a keypress?
(define (yank-around-word)
  (select-around-word)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

;; Yank inner word - cursor goes to start of yanked word
(define (yank-inner-word)
  (select-inner-word)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-word)
  (helix.static.extend_next_word_end)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-long-word)
  (helix.static.extend_next_long_word_end)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-prev-word)
  (helix.static.extend_prev_word_start)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-prev-long-word)
  (helix.static.extend_prev_long_word_start)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-line-end)
  (helix.static.extend_to_line_end)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-line-start)
  (helix.static.extend_to_line_start)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (yank-line-start-non-whitespace)
  (helix.static.extend_to_first_nonwhitespace)
  (helix.static.yank_main_selection_to_clipboard)
  (helix.static.flip_selections)
  (helix.static.collapse_selection))

(define (evil-yank-line)
  (define start-pos (cursor-position))
  (helix.static.extend_to_line_bounds)
  (helix.static.yank_main_selection_to_clipboard)
  
  ;; Flash the selection briefly (if highlight_selections exists)
  ;; This provides visual feedback
  ;; (when (defined? 'helix.static.highlight_selections)
  ;;   (helix.static.highlight_selections))
  
  (helix.static.normal_mode)
  (helix.static.collapse_selection)
  
  (define current-pos (cursor-position))
  (define distance (- start-pos current-pos))
  (cond
    [(> distance 0) (move-right-n distance)]
    [(< distance 0) (move-left-n (- distance))]))

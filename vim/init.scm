(require (prefix-in helix. "helix/commands.scm"))
(require (prefix-in helix.static. "helix/static.scm"))

(require "helix/configuration.scm")
(require "helix/keymaps.scm")
(require "helix/editor.scm")
(require "helix/misc.scm")
(require "helix/ext.scm")
(require "helix/components.scm")

(require "change-motions.scm")
(require "delete-motions.scm")
(require "normal-motions.scm")
(require "visual-motions.scm")
(require "yank-motions.scm")
(require "utils.scm")

(define vim-keybindings
  (keymap (normal (l ":move-char-right-same-line")
                  (h ":move-char-left-same-line")
                  (k ":move-line-up")
                  (j ":move-line-down")
                  (right ":move-char-right-same-line")
                  (left ":move-char-left-same-line")
                  (up ":move-line-up")
                  (down ":move-line-down")
                  (f ":evil-find-next-char")
                  (F ":evil-find-prev-char")
                  (t ":evil-find-till-char")
                  (T ":evil-till-prev-char")
                  (a ":evil-append-mode")
                  (u ":evil-undo")
                  (w ":evil-next-word-start")
                  (e ":evil-next-word-end")
                  (G ":evil-goto-line-or-last")
                  (V ":visual-line-mode")
                  (A-d "no_op")
                  (A-c "no_op")
                  ;; Selecting the whole file
                  (% "match_brackets")
                  (X "no_op")
                  (A-x "no_op")
                  (p ":clipboard-paste-after")
                  (P ":clipboard-paste-before")
                  ;; TODO: More delete things
                  (d (d ":evil-delete-line") 
                     (w ":evil-delete-word")
                     (W ":evil-delete-long-word")
                     (b ":evil-delete-prev-word")
                     (B ":evil-delete-prev-long-word")
                     (e ":evil-delete-word-end")
                     (E ":evil-delete-long-word-end")
                     (a (w ":evil-delete-around-word")
                        (p ":evil-delete-around-paragraph")
                        (f ":evil-delete-around-function")
                        (c ":evil-delete-around-comment")
                        (e ":evil-delete-around-data-structure")
                        (x ":evil-delete-around-html-tag")
                        (t ":evil-delete-around-type-definition")
                        (T ":evil-delete-around-test")
                        ("{" ":evil-delete-around-curly")
                        ("[" ":evil-delete-around-square")
                        ("(" ":evil-delete-around-paren")
                        ("<" ":evil-delete-around-arrow")
                        ("\"" ":evil-delete-around-double-quote")
                        ("'" ":evil-delete-around-single-quote")
                     )
                     (i (w ":evil-delete-inner-word")
                        (p ":evil-delete-inner-paragraph")
                        (f ":evil-delete-inner-function")
                        (c ":evil-delete-inner-comment")
                        (e ":evil-delete-inner-data-structure")
                        (x ":evil-delete-inner-html-tag")
                        (t ":evil-delete-inner-type-definition")
                        (T ":evil-delete-inner-test")
                        ("{" ":evil-delete-inner-curly")
                        ("[" ":evil-delete-inner-square")
                        ("(" ":evil-delete-inner-paren")
                        ("<" ":evil-delete-inner-arrow")
                        ("\"" ":evil-delete-inner-double-quote")
                        ("'" ":evil-delete-inner-single-quote")
                    )
                  )
                  (c (w ":evil-change-word")
                     (W ":evil-change-long-word")
                     (b ":evil-change-prev-word")
                     (B ":evil-change-prev-long-word")
                     (e ":evil-change-word-end")
                     (E ":evil-change-long-word-end")
                     (a (w ":evil-change-around-word")
                        (p ":evil-change-around-paragraph")
                        (f ":evil-change-around-function")
                        (c ":evil-change-around-comment")
                        (e ":evil-change-around-data-structure")
                        (x ":evil-change-around-html-tag")
                        (t ":evil-change-around-type-definition")
                        (T ":evil-change-around-test")
                        ("{" ":evil-change-around-curly")
                        ("[" ":evil-change-around-square")
                        ("(" ":evil-change-around-paren")
                        ("<" ":evil-change-around-arrow")
                        ("\"" ":evil-change-around-double-quote")
                        ("'" ":evil-change-around-single-quote")
                     )
                     (i (w ":evil-change-inner-word")
                        (p ":evil-change-inner-paragraph")
                        (f ":evil-change-inner-function")
                        (c ":evil-change-inner-comment")
                        (e ":evil-change-inner-data-structure")
                        (x ":evil-change-inner-html-tag")
                        (t ":evil-change-inner-type-definition")
                        (T ":evil-change-inner-test")
                        ("{" ":evil-change-inner-curly")
                        ("[" ":evil-change-inner-square")
                        ("(" ":evil-change-inner-paren")
                        ("<" ":evil-change-inner-arrow")
                        ("\"" ":evil-change-inner-double-quote")
                        ("'" ":evil-change-inner-single-quote")
                    )
                  )
                  (S ":evil-change-line")
                  (x "delete_selection")
                  ;; TODO: More yank things
                  (y (y ":evil-yank-line") 
                     ;; TODO: around/inner long word
                     ;; TODO: paragraph, function, comment, test, html tag, etc.
                     (a 
                       (w ":yank-around-word")
                       (p ":yank-around-paragraph")
                       (f ":yank-around-function")
                       (c ":yank-around-comment")
                       (e ":yank-around-data-structure")
                       (x ":yank-around-html-tag")
                       (t ":yank-around-type-definition")
                       (T ":yank-around-test")
                      ) 
                     (i 
                       (w ":yank-inner-word")
                       (p ":yank-inner-paragraph")
                       (f ":yank-inner-function")
                       (c ":yank-inner-comment")
                       (e ":yank-inner-data-structure")
                       (x ":yank-inner-html-tag")
                       (t ":yank-inner-type-definition")
                       (T ":yank-inner-test")
                     )
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
          (select (a (w ":select-around-word")
                    (p ":select-around-paragraph")
                    (f ":select-around-function")
                    (c ":select-around-comment")
                    (e ":select-around-data-structure")
                    (x ":select-around-html-tag")
                    (t ":select-around-type-definition")
                    (T ":select-around-test")
                    ("{" ":select-around-curly")
                    ("[" ":select-around-square")
                    ("(" ":select-around-paren")
                    ("<" ":select-around-arrow")
                    ("\"" ":select-around-double-quote")
                    ("'" ":select-around-single-quote")
                  )
                  (i (w ":select-inner-word")
                    (p ":select-inner-paragraph")
                    (f ":select-inner-function")
                    (c ":select-inner-comment")
                    (e ":select-inner-data-structure")
                    (x ":select-inner-html-tag")
                    (t ":select-inner-type-definition")
                    (T ":select-inner-test")
                    ("{" ":select-inner-curly")
                    ("[" ":select-inner-square")
                    ("(" ":select-inner-paren")
                    ("<" ":select-inner-arrow")
                    ("\"" ":select-inner-double-quote")
                    ("'" ":select-inner-single-quote"))
                  (h ":extend-char-left-same-line")
                  (l ":extend-char-right-same-line")
                  (j ":extend-line-down")
                  (k ":extend-line-up")
                  (p ":clipboard-paste-after")
                  (P ":clipboard-paste-before")
                  (y ":evil-yank-selection")
                  (left ":extend-char-left-same-line")
                  (right ":extend-char-right-same-line")
                  (down ":extend-line-down")
                  (up ":extend-line-up")
                  (esc ":exit-visual-line-mode")
                )
          (insert (C-d "unindent") (C-t "indent"))))

(define (set-vim-keybindings!)
  (add-global-keybinding vim-keybindings))

(provide set-vim-keybindings!)
(provide 
  ;; change motions
  evil-change-line
  evil-change-word
  evil-change-long-word
  evil-change-prev-word
  evil-change-prev-long-word
  evil-change-word-end
  evil-change-long-word-end
  evil-change-around-word
  evil-change-inner-word
  evil-change-around-paragraph
  evil-change-inner-paragraph
  evil-change-around-function
  evil-change-inner-function
  evil-change-around-comment
  evil-change-inner-comment
  evil-change-around-data-structure
  evil-change-inner-data-structure
  evil-change-around-html-tag
  evil-change-inner-html-tag
  evil-change-around-type-definition
  evil-change-inner-type-definition
  evil-change-around-test
  evil-change-inner-test
  evil-change-around-curly
  evil-change-inner-curly
  evil-change-around-square
  evil-change-inner-square
  evil-change-inner-paren
  evil-change-around-paren
  evil-change-around-double-quote
  evil-change-inner-double-quote
  evil-change-around-single-quote
  evil-change-inner-single-quote
  evil-change-around-arrow
  evil-change-inner-arrow
  evil-change-inner-square
  evil-change-inner-paren
  evil-change-around-paren
  evil-change-around-double-quote
  evil-change-inner-double-quote
  evil-change-around-single-quote
  evil-change-inner-single-quote
  evil-change-around-arrow
  evil-change-inner-arrow

  ;; delete motions
  evil-delete-line
  evil-delete-word
  evil-delete-word-end
  evil-delete-long-word-end
  evil-delete-long-word
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

  ;; normal motions
  evil-undo
  evil-append-mode
  move-char-right-same-line
  move-char-left-same-line
  move-line-up-impl
  move-line-up
  move-line-down-impl
  move-line-down
  evil-find-next-char
  evil-find-prev-char
  evil-find-till-char
  evil-till-prev-char
  evil-goto-line-or-last
  evil-next-word-start
  evil-next-word-end
  evil-prev-word-start
  evil-prev-long-word-start
  evil-next-long-word-start
  evil-next-long-word-end
  visual-line-mode

  ;; visual motions
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
  exit-visual-line-mode
  
  ;; yank motions
  evil-yank-selection
  yank-around-word
  yank-inner-word
  yank-word
  yank-long-word
  yank-prev-word
  yank-prev-long-word
  yank-line-end
  yank-line-start
  yank-line-start-non-whitespace
  evil-yank-line
)

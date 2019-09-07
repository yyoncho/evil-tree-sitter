;;; evil-tree-sitter.el --- Evil Tree sitter integration  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Ivan Yonchovski

;; Author: Ivan Yonchovski <yyoncho@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'dash)
(require 'tree-sitter)
(require 'evil)

(defun evil-tree-sitter-get-parent-matching (test-fn)
  (let* ((range (vector (1- (line-number-at-pos))
                        (current-column)))
         (parent (ts-get-descendant-for-point-range
                  (ts-root-node tree-sitter-tree)
                  range
                  range)))
    (while (and parent (not (funcall test-fn parent)))
      (setq parent (ts-get-parent parent)))
    parent))

(evil-define-text-object evil-tree-sitter-statement (count &rest _rest)
  (let ((node (evil-tree-sitter-get-parent-matching
               (lambda (node)
                 (member (ts-node-type node)
                         '("program"
                           "package_declaration"
                           "import_declaration"
                           "class_declaration"
                           "field_declaration"
                           "static_initializer"
                           "constructor_declaration"
                           "method_declaration"
                           "switch_statement"
                           "expression_statement"
                           "if_statement"
                           "while_statement"
                           "for_statement"
                           "try_statement"
                           "do_statement"
                           "comment"))))))
    (-let [[beg end] (ts-node-range node)]
      (list (1+ beg) (1+ end)))))

(evil-define-text-object evil-tree-sitter-statement (count &rest _rest)
  (let ((node (evil-tree-sitter-get-parent-matching
               (lambda (node)
                 (member (ts-node-type node)
                         '("program"
                           "package_declaration"
                           "import_declaration"
                           "class_declaration"
                           "field_declaration"
                           "static_initializer"
                           "constructor_declaration"
                           "method_declaration"
                           "switch_statement"
                           "expression_statement"
                           "if_statement"
                           "while_statement"
                           "for_statement"
                           "try_statement"
                           "do_statement"
                           "comment"))))))
    (-let [[beg end] (ts-node-range node)]
      (list (1+ beg) (1+ end)))))

(define-key evil-outer-text-objects-map "s" #'evil-tree-sitter-statement)


(with-current-buffer "App.java"
  (when-let ((node (ts-get-descendant-for-byte-range
                    (ts-root-node tree-sitter-tree)
                    (1- (point))
                    (1- (point-at-eol))))
             (end-point (cond
                         ((<= (1- (point))
                              (ts-node-start-byte node)
                              (1- (point-at-eol)))
                          (ts-node-end-byte node))
                         (t (or (ts-reduce-children (lambda (result n)
                                                      (if (<= (1- (point))
                                                              (ts-node-start-byte n)
                                                              (1- (point-at-eol)))
                                                          (ts-node-end-byte n)
                                                        result))
                                                    nil
                                                    node)

                                (1- (point-at-eol)))))))
    (kill-region (point) (1+ end-point))))


(with-current-buffer "App.java"
  (when-let ((node (ts-get-descendant-for-byte-range
                    (ts-root-node tree-sitter-tree)
                    (1- (point))
                    (1- (point)))))
    (while (<= (ts-node-end-byte (ts-get-parent node)) (1- (point-at-eol)))
      (setq node (ts-get-parent node)))
    (with-temp-buffer
      (tree-sitter-debug--display-node node 0)
      (buffer-string)))))

(provide 'evil-tree-sitter)
;;; evil-tree-sitter.el ends here

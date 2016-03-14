(load "C:/Users/welcome/quicklisp/setup.lisp")
(ql:quickload :cl-mongo)
(use-package :cl-mongo)

(db.use "kliq")
(print (get-element "place" (car (docs (db.find "workplaces" (kv "tag" "common"))))))
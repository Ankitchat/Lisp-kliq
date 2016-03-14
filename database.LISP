"Using both Redis and MongoDb as Databases. Starting the Connection."

(load "C:/Users/welcome/quicklisp/setup.lisp")
(load "F:/Unnamed.LISP")


(ql:quickload :bordeaux-threads)
(ql:quickload :cl-mongo)
(ql:quickload :cl-redis)
(ql:quickload :trivial-shell)
(use-package :cl-mongo)
(use-package :redis)



(defvar options nil)
(defvar opened 0)
(setq toopen (make-hash-table)) 
(defun parse-all(dir che) 									"Used to parse and walk directory. Opens up first thing it finds."
	(dolist (tokens dir)
		(if (not (equalp (cadr (pathname-directory tokens)) "System Volume Information"))
			(progn (if (search che (namestring tokens))
				(push tokens options))
			(if (equalp "" (file-namestring tokens))
				(setf re (parse-all (list-directory tokens) che))))
			)
		 ))

(defun django-check(dir)
	(if (not (pathname-type dir))
	(if (probe-file (concatenate 'string (namestring dir) "/manage.py"))
		(setf result (trivial-shell:shell-command (concatenate 'string "start python \"" 
			(concatenate 'string (namestring dir) "/manage.py") "\" runserver")))))
	)

(defun open-files (opentype)
	(if (not (equalp (red-get (pathname-type opentype)) "no"))
		(if (or (red-get (pathname-type opentype))
			(and (not (equalp "" (file-namestring opentype)))
				(not (pathname-type opentype))
				 ))
				(trivial-shell:shell-command (concatenate 'string "start subl \"" (namestring opentype) "\""))
				(progn (trivial-shell:shell-command (concatenate 'string "explorer \"" (namestring opentype) "\""))
					(django-check opentype)))
		(trivial-shell:shell-command (concatenate 'string "explorer \"" (namestring opentype) "\"")))
	)


(defun more ()
	(red-set "more" nil)
	(loop for new in '(3 4 5) 
		if (gethash new toopen) 
		do (progn (red-set "more" (gethash new toopen))(remhash new toopen)))
	)


(defun open-up (key)											"Used to open correct window from toopen hash table."
	(if (< opened 2)
		(if (gethash key toopen)
			(progn (open-files (gethash key toopen))
							(remhash key toopen)(incf opened))
		)))    

(defun choose-best(che)
	(if options
		(dolist (other options)
			(if (equalp che (pathname-name other))
				(if (equalp "" (file-namestring other))
						(trivial-shell:shell-command (concatenate 'string "explorer \"" (namestring other) "\""))
						(if (not (equalp (red-get (pathname-type other)) "no"))
							(setf (gethash '2 toopen) other)
							(setf (gethash '3 toopen) other)
							)							
						)
				(if (equalp "" (file-namestring other))
					(setf (gethash '1 toopen) other)
					(if (not (equalp (red-get (pathname-type other)) "no"))
							(setf (gethash '4 toopen) other)
							(setf (gethash '5 toopen) other)
							)
					)
				)
			)
		(print "Not HERE"))
	)


(defun find-things(collection document thing)
	(db.use "kliq")
	(defvar a)
	(setf a (get-element "place" (car (docs (db.find "workplaces" (kv "tag" document))))))
	(setf w (list-directory a))
	(parse-all w thing)
	(choose-best thing)
	(dotimes (n 6) (open-up n))
	(more)
	)

(redis:disconnect )
(redis:connect :host "localhost")
(find-things "workplaces" "series" (car *args*))
(redis:disconnect)
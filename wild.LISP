(defun component-present-p (given)
  (and given (not (eql given :unspecific))))
(defun directory-path-p (p)
  (and (not (component-present-p (pathname-name p)))
       (not (component-present-p (pathname-type p)))
       p))
(defun pathname-as-directory (name)
  (let ((pathname (pathname name)))
    (when (wild-pathname-p pathname)
      (error "can't convert"))
    (if (not (directory-path-p name))
        (make-pathname
         :directory (append (or (pathname-directory pathname) (list :relative)) (list (file-namestring pathname)))
         :name nil
         :type nil
         :defaults pathname)
      pathname)))
(defun wild-maker (dir)
  (make-pathname 
   :name :wild
   :type #-clisp :wild #+clisp nil
   :defaults (pathname-as-directory dir)))
(defun list-directory (dirname)
  (when (wild-pathname-p dirname)
    (error "can't list non concrete"))
  (directory (wild-maker dirname)))
(defun file-exists-p (pathname)
  #+lispworks
  (probe-file pathname)
  #+(or allergo cmu)
  (or (probe-file (pathname-as-directory pathname))
      (probe-file pathname))
  #+clisp
  (or (ignore-errors 
        (probe-file (pathname-as-file pathname)))
      (ignore-errors 
        (let ((directory-form (pathname-as-directory pathname)))
          (when (ext:probe-directory directory-form)
            directory-form)))))
(defun walk-directory (dirname fn &key directories (test (constantly t)))
  (labels 
      ((walk (name)
         (cond 
          ((directory-path-p name)
           (when (and directories (funcall test name))
             (funcall fn name))
           (dolist (x (list-directory name))(walk x)))
          ((funcall test name)(funcall fn name)))))
    (walk (pathname-as-directory dirname))))





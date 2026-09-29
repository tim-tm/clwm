(load "./raylib.cl")

(defclass window ()
  ((user-id :initarg :user-id
            :initform (error "user-id required")
            :accessor :user-id)))

(defparameter *client-count* 0)
(defparameter *clients* '())

(defun render ()
  (raylib:InitWindow 800 600 "test")
  (raylib:SetTargetFPS 60)
  
  (loop
    (raylib:BeginDrawing)
    (raylib:ClearBackground #xffffffff)
    (raylib:EndDrawing)
    (when (= (raylib:WindowShouldClose) 1) (return)))
  
  (raylib:CloseWindow))

(sb-thread:make-thread #'render)

(require 'sb-bsd-sockets)

(defun cleanup-client (connection user-id)
  (sb-bsd-sockets:socket-close connection)
  (remove user-id *clients*) 
  (decf *client-count*))

(defun handle-client (connection user-id)
  (let ((stream (sb-bsd-sockets:socket-make-stream
                  connection
                  :input t
                  :output t
                  :buffering :none)))
    (unwind-protect
      (loop for expr = (read stream nil 'eof)
        until (eq expr 'eof)
        do (eval expr))
      (cleanup-client connection user-id))))

(defun create-client (connection)
  (incf *client-count*)
  (push *client-count* *clients*)
  (format t "clients: ~A~%" *clients*)
  (handle-client connection *client-count*))

(defun start-unix-server (socket-path)
  (when (probe-file socket-path)
    (delete-file socket-path))
  (let ((server (make-instance 'sb-bsd-sockets:local-socket :type :stream)))
    (sb-bsd-sockets:socket-bind server socket-path)
    (sb-bsd-sockets:socket-listen server 5)
    (format t "Server listening on ~A~%" socket-path)
    (unwind-protect
      (loop
        (let ((connection (sb-bsd-sockets:socket-accept server)))
          (sb-thread:make-thread (lambda () (create-client connection)))))
      (sb-bsd-sockets:socket-close server))))

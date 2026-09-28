(defpackage :raylib
  (:use :cl :sb-alien)
  (:export
    #:InitWindow
    #:CloseWindow
    #:WindowShouldClose
    #:BeginDrawing
    #:EndDrawing
    #:ClearBackground
    #:SetTargetFPS
  ))
(in-package :raylib)

(define-alien-routine "InitWindow" void (width int) (height int) (title c-string))
(define-alien-routine "CloseWindow" void)
(define-alien-routine "WindowShouldClose" integer)
(define-alien-routine "BeginDrawing" void)
(define-alien-routine "EndDrawing" void)
; yes, raylib expects the "Color" structure but it's fine to pass it as an integer instead
; raylib uses unsigned char to store each component and there are 4 components in total (RGBA)
; so it should add up to 32bit
; (at least on most platforms or at least on the platforms I care about)
(define-alien-routine "ClearBackground" void (color (unsigned 32)))
(define-alien-routine "SetTargetFPS" void (fps int))

(load-shared-object "libraylib.so")

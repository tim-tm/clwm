(load "./raylib.cl")

(raylib:InitWindow 800 600 "test")
(raylib:SetTargetFPS 60)

(loop
  (raylib:BeginDrawing)
  (raylib:ClearBackground #xffffffff)
  (raylib:EndDrawing)
  (when (= (raylib:WindowShouldClose) 1) (return 42)))

(raylib:CloseWindow)

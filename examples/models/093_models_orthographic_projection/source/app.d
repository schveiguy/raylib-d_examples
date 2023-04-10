/*******************************************************************************************
*
*   raylib [models] example - Show the difference between perspective and orthographic projection
*
*   Example originally created with raylib 2.0, last time updated with raylib 3.7
*
*   Example contributed by Max Danielsson (@autious) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2018-2023 Max Danielsson (@autious) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

const float FOVY_PERSPECTIVE   = 45.0f;
const float WIDTH_ORTHOGRAPHIC = 10.0f;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - geometric shapes");

    // Define the camera to look into our 3d world
    Camera camera = {
        Vector3( 0.0f, 10.0f, 10.0f ),
        Vector3( 0.0f, 0.0f, 0.0f   ),
        Vector3( 0.0f, 1.0f, 0.0f   ),
        FOVY_PERSPECTIVE,
        CameraProjection.CAMERA_PERSPECTIVE
    };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyPressed(KeyboardKey.KEY_SPACE))
        {
            if (camera.projection == CameraProjection.CAMERA_PERSPECTIVE)
            {
                camera.fovy = WIDTH_ORTHOGRAPHIC;
                camera.projection = CameraProjection.CAMERA_ORTHOGRAPHIC;
            }
            else
            {
                camera.fovy = FOVY_PERSPECTIVE;
                camera.projection = CameraProjection.CAMERA_PERSPECTIVE;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                DrawCube(Vector3(-4.0f, 0.0f, 2.0f), 2.0f, 5.0f, 2.0f, Colors.RED);
                DrawCubeWires(Vector3(-4.0f, 0.0f, 2.0f), 2.0f, 5.0f, 2.0f, Colors.GOLD);
                DrawCubeWires(Vector3(-4.0f, 0.0f, -2.0f), 3.0f, 6.0f, 2.0f, Colors.MAROON);

                DrawSphere(Vector3(-1.0f, 0.0f, -2.0f), 1.0f, Colors.GREEN);
                DrawSphereWires(Vector3(1.0f, 0.0f, 2.0f), 2.0f, 16, 16, Colors.LIME);

                DrawCylinder(Vector3(4.0f, 0.0f, -2.0f), 1.0f, 2.0f, 3.0f, 4, Colors.SKYBLUE);
                DrawCylinderWires(Vector3(4.0f, 0.0f, -2.0f), 1.0f, 2.0f, 3.0f, 4, Colors.DARKBLUE);
                DrawCylinderWires(Vector3(4.5f, -1.0f, 2.0f), 1.0f, 1.0f, 2.0f, 6, Colors.BROWN);

                DrawCylinder(Vector3(1.0f, 0.0f, -4.0f), 0.0f, 1.5f, 3.0f, 8, Colors.GOLD);
                DrawCylinderWires(Vector3(1.0f, 0.0f, -4.0f), 0.0f, 1.5f, 3.0f, 8, Colors.PINK);

                DrawGrid(10, 1.0f);        // Draw a grid

            EndMode3D();

            DrawText("Press Spacebar to switch camera type", 10, GetScreenHeight() - 30, 20, Colors.DARKGRAY);

            if (camera.projection == CameraProjection.CAMERA_ORTHOGRAPHIC) {
                DrawText("ORTHOGRAPHIC", 10, 40, 20, Colors.BLACK);
            }
            else if (camera.projection == CameraProjection.CAMERA_PERSPECTIVE) {
                DrawText("PERSPECTIVE", 10, 40, 20, Colors.BLACK);
            }

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

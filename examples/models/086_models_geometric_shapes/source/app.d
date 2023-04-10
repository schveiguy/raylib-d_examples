/*******************************************************************************************
*
*   raylib [models] example - Draw some basic geometric shapes (cube, sphere, cylinder...)
*
*   Example originally created with raylib 1.0, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

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
    Camera camera;
    camera.position = Vector3( 0.0f, 10.0f, 10.0f );
    camera.target = Vector3( 0.0f, 0.0f, 0.0f );
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );
    camera.fovy = 45.0f;
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
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

                DrawCapsule     (Vector3(-3.0f, 1.5f, -4.0f), Vector3(-4.0f, -1.0f, -4.0f), 1.2f, 8, 8, Colors.VIOLET);
                DrawCapsuleWires(Vector3(-3.0f, 1.5f, -4.0f), Vector3(-4.0f, -1.0f, -4.0f), 1.2f, 8, 8, Colors.PURPLE);

                DrawGrid(10, 1.0f);        // Draw a grid

            EndMode3D();

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

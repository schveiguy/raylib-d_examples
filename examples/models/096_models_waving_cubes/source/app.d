/*******************************************************************************************
*
*   raylib [models] example - Waving cubes
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Codecat (@codecat) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Codecat (@codecat) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import core.stdc.math; // Required for: sinf()

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - waving cubes");

    // Initialize the camera
    Camera3D camera;
    camera.position = Vector3( 30.0f, 20.0f, 30.0f );        // Camera position
    camera.target = Vector3( 0.0f, 0.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 70.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    // Specify the amount of blocks in each direction
    const int numBlocks = 15;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        double time = GetTime();

        // Calculate time scale for cube position and size
        float scale = (2.0f + cast(float)sin(time))*0.7f;

        // Move camera around the scene
        double cameraTime = time*0.3;
        camera.position.x = cast(float)cos(cameraTime)*40.0f;
        camera.position.z = cast(float)sin(cameraTime)*40.0f;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                DrawGrid(10, 5.0f);

                for (int x = 0; x < numBlocks; x++)
                {
                    for (int y = 0; y < numBlocks; y++)
                    {
                        for (int z = 0; z < numBlocks; z++)
                        {
                            // Scale of the blocks depends on x/y/z positions
                            float blockScale = (x + y + z)/30.0f;

                            // Scatter makes the waving effect by adding blockScale over time
                            float scatter = sinf(blockScale*20.0f + cast(float)(time*4.0f));

                            // Calculate the cube position
                            Vector3 cubePos = {
                                cast(float)(x - numBlocks/2)*(scale*3.0f) + scatter,
                                cast(float)(y - numBlocks/2)*(scale*2.0f) + scatter,
                                cast(float)(z - numBlocks/2)*(scale*3.0f) + scatter
                            };

                            // Pick a color with a hue depending on cube position for the rainbow color effect
                            Color cubeColor = ColorFromHSV(cast(float)(((x + y + z)*18)%360), 0.75f, 0.9f);

                            // Calculate cube size
                            float cubeSize = (2.4f - scale)*blockScale;

                            // And finally, draw the cube!
                            DrawCube(cubePos, cubeSize, cubeSize, cubeSize, cubeColor);
                        }
                    }
                }

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

/*******************************************************************************************
*
*   raylib [models] example - Load 3d model with animations and play them
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.5
*
*   Example contributed by Culacant (@culacant) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Culacant (@culacant) and Ramon Santamaria (@raysan5)
*
********************************************************************************************
*
*   NOTE: To export a model from blender, make sure it is not posed, the vertices need to be
*         in the same position as they would be in edit mode and the scale of your models is
*         set to 0. Scaling can be done from the export menu.
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - model animation");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 10.0f, 10.0f, 10.0f );        // Camera position
    camera.target = Vector3( 0.0f, 0.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera mode type

    auto file1 = (thisExePath().dirName ~ "/../resources/models/iqm/guy.iqm").buildNormalizedPath.toStringz;
    Model model = LoadModel(file1);                          // Load the animated model mesh and basic data

    auto file2 = (thisExePath().dirName ~ "/../resources/models/iqm/guytex.png").buildNormalizedPath.toStringz;
    Texture2D texture = LoadTexture(file2);                  // Load model texture and set material
    SetMaterialTexture(&model.materials[0], MATERIAL_MAP_DIFFUSE, texture);     // Set model material map texture

    Vector3 position = { 0.0f, 0.0f, 0.0f };                 // Set model position

    // Load animation data
    uint animsCount = 0;
    auto file3 = (thisExePath().dirName ~ "/../resources/models/iqm/guyanim.iqm").buildNormalizedPath.toStringz;
    ModelAnimation *anims = LoadModelAnimations(file3, &animsCount);
    int animFrameCounter = 0;

    DisableCursor();                    // Catch cursor
    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);

        // Play animation when spacebar is held down
        if (IsKeyDown(KeyboardKey.KEY_SPACE))
        {
            animFrameCounter++;
            UpdateModelAnimation(model, anims[0], animFrameCounter);
            if (animFrameCounter >= anims[0].frameCount) {
                animFrameCounter = 0;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                DrawModelEx(
                    model,
                    position,
                    Vector3( 1.0f, 0.0f, 0.0f ),
                    -90.0f,
                    Vector3( 1.0f, 1.0f, 1.0f ),
                    Colors.WHITE
                );

                for (int i = 0; i < model.boneCount; i++)
                {
                    DrawCube(anims[0].framePoses[animFrameCounter][i].translation, 0.2f, 0.2f, 0.2f, Colors.RED);
                }

                DrawGrid(10, 1.0f);         // Draw a grid

            EndMode3D();

            DrawText("PRESS SPACE to PLAY MODEL ANIMATION", 10, 10, 20, Colors.MAROON);
            DrawText("(c) Guy IQM 3D model by @culacant", screenWidth - 200, screenHeight - 20, 10, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);                     // Unload texture
    UnloadModelAnimations(anims, animsCount);   // Unload model animations data
    UnloadModel(model);                         // Unload model

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

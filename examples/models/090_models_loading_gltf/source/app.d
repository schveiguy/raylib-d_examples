/*******************************************************************************************
*
*   raylib [models] example - loading gltf with animations
*
*   LIMITATIONS:
*     - Only supports 1 armature per file, and skips loading it if there are multiple armatures
*     - Only supports linear interpolation (default method in Blender when checked
*       "Always Sample Animations" when exporting a GLTF file)
*     - Only supports translation/rotation/scale animation channel.path,
*       weights not considered (i.e. morph targets)
*
*   Example originally created with raylib 3.7, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - loading gltf");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 5.0f, 5.0f, 5.0f );           // Camera position
    camera.target = Vector3( 0.0f, 2.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    // Load gltf model
    auto file1 = (thisExePath().dirName ~ "/../resources/models/gltf/robot.glb").buildNormalizedPath.toStringz;
    Model model = LoadModel(file1);

    // Load gltf model animations
    int animsCount = 0;
    uint animIndex = 0;
    uint animCurrentFrame = 0;

    auto file2 = (thisExePath().dirName ~ "/../resources/models/gltf/robot.glb").buildNormalizedPath.toStringz;
    ModelAnimation *modelAnimations = LoadModelAnimations(file2, &animsCount);

    Vector3 position = { 0.0f, 0.0f, 0.0f };    // Set model position

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_THIRD_PERSON);
        // Select current animation
        if (IsKeyPressed(KeyboardKey.KEY_UP)) {
            animIndex = (animIndex + 1)%animsCount;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_DOWN)) {
            animIndex = (animIndex + animsCount - 1)%animsCount;
        }

        // Update model animation
        ModelAnimation anim = modelAnimations[animIndex];
        animCurrentFrame = (animCurrentFrame + 1)%anim.frameCount;
        UpdateModelAnimation(model, anim, animCurrentFrame);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, position, 1.0f, Colors.WHITE);    // Draw animated model
                DrawGrid(10, 1.0f);

            EndMode3D();

            DrawText("Use the UP/DOWN arrow keys to switch animation", 10, 10, 20, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadModel(model);         // Unload model and meshes/material

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

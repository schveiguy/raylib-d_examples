/*******************************************************************************************
*
*   raylib [models] example - Load models vox (MagicaVoxel)
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example contributed by Johann Nadalutti (@procfxgen) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2023 Johann Nadalutti (@procfxgen) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;

const int MAX_VOX_FILES = 3;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    string[MAX_VOX_FILES] voxFileNames;
    voxFileNames[0] = (thisExePath().dirName ~ "/../resources/models/vox/chr_knight.vox").buildNormalizedPath;
    voxFileNames[1] = (thisExePath().dirName ~ "/../resources/models/vox/chr_sword.vox").buildNormalizedPath;
    voxFileNames[2] = (thisExePath().dirName ~ "/../resources/models/vox/monu9.vox").buildNormalizedPath;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - magicavoxel loading");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 10.0f, 10.0f, 10.0f );        // Camera position
    camera.target = Vector3( 0.0f, 0.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    // Load MagicaVoxel files
    Model[MAX_VOX_FILES] models;

    for (int i = 0; i < MAX_VOX_FILES; i++)
    {
        // Load VOX file and measure time
        double t0 = GetTime()*1000.0;
        models[i] = LoadModel(voxFileNames[i].toStringz);
        double t1 = GetTime()*1000.0;

        TraceLog(TraceLogLevel.LOG_WARNING, TextFormat("[%s] File loaded in %.3f ms", voxFileNames[i].toStringz, t1 - t0));

        // Compute model translation matrix to center model on draw position (0, 0 , 0)
        BoundingBox bb = GetModelBoundingBox(models[i]);
        Vector3 center = { 0.0, 0.0, 0.0 };
        center.x = bb.min.x  + (((bb.max.x - bb.min.x)/2));
        center.z = bb.min.z  + (((bb.max.z - bb.min.z)/2));

        Matrix matTranslate = MatrixTranslate(-center.x, 0, -center.z);
        models[i].transform = matTranslate;
    }

    int currentModel = 0;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_ORBITAL);

        // Cycle between models on mouse click
        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
            currentModel = (currentModel + 1)%MAX_VOX_FILES;
        }

        // Cycle between models on key pressed
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT))
        {
            currentModel++;
            if (currentModel >= MAX_VOX_FILES) currentModel = 0;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_LEFT))
        {
            currentModel--;
            if (currentModel < 0) currentModel = MAX_VOX_FILES - 1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            // Draw 3D model
            BeginMode3D(camera);

                DrawModel(models[currentModel], Vector3(0, 0, 0), 1.0f, Colors.WHITE);
                DrawGrid(10, 1.0);

            EndMode3D();

            // Display info
            DrawRectangle(10, 400, 310, 30, Fade(Colors.SKYBLUE, 0.5f));
            DrawRectangleLines(10, 400, 310, 30, Fade(Colors.DARKBLUE, 0.5f));
            DrawText("MOUSE LEFT BUTTON to CYCLE VOX MODELS", 40, 410, 10, Colors.BLUE);
            DrawText(TextFormat("File: %s", GetFileName(voxFileNames[currentModel].toStringz)), 10, 10, 20, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload models data (GPU VRAM)
    for (int i = 0; i < MAX_VOX_FILES; i++) {
        UnloadModel(models[i]);
    }

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

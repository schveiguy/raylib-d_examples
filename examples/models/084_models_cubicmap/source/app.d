/*******************************************************************************************
*
*   raylib [models] example - Cubicmap loading and drawing
*
*   Example originally created with raylib 1.8, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - cubesmap loading and drawing");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 16.0f, 14.0f, 16.0f );     // Camera position
    camera.target = Vector3( 0.0f, 0.0f, 0.0f );          // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );              // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                    // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE;                 // Camera projection type

    auto file1 = (thisExePath().dirName ~ "/../resources/cubicmap.png").buildNormalizedPath.toStringz;
    Image image = LoadImage(file1);      // Load cubicmap image (RAM)
    Texture2D cubicmap = LoadTextureFromImage(image);       // Convert image to texture to display (VRAM)

    Mesh mesh = GenMeshCubicmap(image, Vector3( 1.0f, 1.0f, 1.0f ));
    Model model = LoadModelFromMesh(mesh);

    // NOTE: By default each cube is mapped to one part of texture atlas
    auto file2 = (thisExePath().dirName ~ "/../resources/cubicmap_atlas.png").buildNormalizedPath.toStringz;
    Texture2D texture = LoadTexture(file2);    // Load map texture
    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;    // Set map diffuse texture

    Vector3 mapPosition = { -16.0f, 0.0f, -8.0f };          // Set model position

    UnloadImage(image);     // Unload cubesmap image from RAM, already uploaded to VRAM

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_ORBITAL);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                DrawModel(model, mapPosition, 1.0f, Colors.WHITE);

            EndMode3D();

            DrawTextureEx(cubicmap, Vector2(screenWidth - cubicmap.width*4.0f - 20, 20.0f), 0.0f, 4.0f, Colors.WHITE);
            DrawRectangleLines(screenWidth - cubicmap.width*4 - 20, 20, cubicmap.width*4, cubicmap.height*4, Colors.GREEN);

            DrawText("cubicmap image used to", 658, 90, 10, Colors.GRAY);
            DrawText("generate map 3d model", 658, 104, 10, Colors.GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(cubicmap);    // Unload cubicmap texture
    UnloadTexture(texture);     // Unload map texture
    UnloadModel(model);         // Unload map model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

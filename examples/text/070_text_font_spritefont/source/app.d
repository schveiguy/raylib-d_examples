/*******************************************************************************************
*
*   raylib [text] example - Sprite font loading
*
*   NOTE: Sprite fonts should be generated following this conventions:
*
*     - Characters must be ordered starting with character 32 (Space)
*     - Every character must be contained within the same Rectangle height
*     - Every character and every line must be separated by the same distance (margin/padding)
*     - Rectangles must be defined by a MAGENTA color background
*
*   Following those constraints, a font can be provided just by an image,
*   this is quite handy to avoid additional font descriptor files (like BMFonts use).
*
*   Example originally created with raylib 1.0, last time updated with raylib 1.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [text] example - sprite font loading");

    string msg1 = "THIS IS A custom SPRITE FONT...";
    string msg2 = "...and this is ANOTHER CUSTOM font...";
    string msg3 = "...and a THIRD one! GREAT! :D";

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
    auto file1 = (thisExePath().dirName ~ "/../resources/custom_mecha.png").buildNormalizedPath.toStringz;
    Font font1 = LoadFont(file1);          // Font loading

    auto file2 = (thisExePath().dirName ~ "/../resources/custom_alagard.png").buildNormalizedPath.toStringz;
    Font font2 = LoadFont(file2);        // Font loading

    auto file3 = (thisExePath().dirName ~ "/../resources/custom_jupiter_crash.png").buildNormalizedPath.toStringz;
    Font font3 = LoadFont(file3);  // Font loading

    Vector2 fontPosition1 = { screenWidth/2.0f - MeasureTextEx(font1, msg1.toStringz, cast(float)font1.baseSize, -3).x/2,
                              screenHeight/2.0f - font1.baseSize/2.0f - 80.0f };

    Vector2 fontPosition2 = { screenWidth/2.0f - MeasureTextEx(font2, msg2.toStringz, cast(float)font2.baseSize, -2.0f).x/2.0f,
                              screenHeight/2.0f - font2.baseSize/2.0f - 10.0f };

    Vector2 fontPosition3 = { screenWidth/2.0f - MeasureTextEx(font3, msg3.toStringz, cast(float)font3.baseSize, 2.0f).x/2.0f,
                              screenHeight/2.0f - font3.baseSize/2.0f + 50.0f };

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update variables here...
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawTextEx(font1, msg1.toStringz, fontPosition1, cast(float)font1.baseSize, -3, Colors.WHITE);
            DrawTextEx(font2, msg2.toStringz, fontPosition2, cast(float)font2.baseSize, -2, Colors.WHITE);
            DrawTextEx(font3, msg3.toStringz, fontPosition3, cast(float)font3.baseSize, 2, Colors.WHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadFont(font1);      // Font unloading
    UnloadFont(font2);      // Font unloading
    UnloadFont(font3);      // Font unloading

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

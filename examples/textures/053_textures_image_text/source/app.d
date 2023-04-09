/*******************************************************************************************
*
*   raylib [texture] example - Image text drawing using TTF generated font
*
*   Example originally created with raylib 1.8, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [texture] example - image text drawing");

    auto file1 = (thisExePath().dirName ~ "/../resources/parrots.png").buildNormalizedPath.toStringz;
    Image parrots = LoadImage(file1); // Load image in CPU memory (RAM)

    // TTF Font loading with custom generation parameters
    auto file2 = (thisExePath().dirName ~ "/../resources/KAISG.ttf").buildNormalizedPath.toStringz;
    Font font = LoadFontEx(file2, 64, null, 0);

    // Draw over image using custom font
    ImageDrawTextEx(&parrots, font, "[Parrots font drawing]", Vector2( 20.0f, 20.0f ), cast(float)font.baseSize, 0.0f, Colors.RED);

    Texture2D texture = LoadTextureFromImage(parrots);  // Image converted to texture, uploaded to GPU memory (VRAM)
    UnloadImage(parrots);   // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

    Vector2 position = { cast(float)(screenWidth/2 - texture.width/2), cast(float)(screenHeight/2 - texture.height/2 - 20) };

    bool showFont = false;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(KeyboardKey.KEY_SPACE)) showFont = true;
        else showFont = false;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            if (!showFont)
            {
                // Draw texture with text already drawn inside
                DrawTextureV(texture, position, Colors.WHITE);

                // Draw text directly using sprite font
                DrawTextEx(
                    font,
                    "[Parrots font drawing]",
                    Vector2( position.x + 20, position.y + 20 + 280 ),
                    cast(float)font.baseSize,
                    0.0f,
                    Colors.WHITE
                );
            }
            else {
                DrawTexture(font.texture, screenWidth/2 - font.texture.width/2, 50, Colors.BLACK);
            }

            DrawText("PRESS SPACE to SHOW FONT ATLAS USED", 290, 420, 10, Colors.DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);     // Texture unloading

    UnloadFont(font);           // Unload custom font

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

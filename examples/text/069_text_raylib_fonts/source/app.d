/*******************************************************************************************
*
*   raylib [text] example - raylib fonts loading
*
*   NOTE: raylib is distributed with some free to use fonts (even for commercial pourposes!)
*         To view details and credits for those fonts, check raylib license file
*
*   Example originally created with raylib 1.7, last time updated with raylib 3.7
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

const int MAX_FONTS = 8;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [text] example - raylib fonts");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    Font[MAX_FONTS] fonts;

    auto font0 = (thisExePath().dirName ~ "/../resources/fonts/alagard.png").buildNormalizedPath.toStringz;
    auto font1 = (thisExePath().dirName ~ "/../resources/fonts/pixelplay.png").buildNormalizedPath.toStringz;
    auto font2 = (thisExePath().dirName ~ "/../resources/fonts/mecha.png").buildNormalizedPath.toStringz;
    auto font3 = (thisExePath().dirName ~ "/../resources/fonts/setback.png").buildNormalizedPath.toStringz;
    auto font4 = (thisExePath().dirName ~ "/../resources/fonts/romulus.png").buildNormalizedPath.toStringz;
    auto font5 = (thisExePath().dirName ~ "/../resources/fonts/pixantiqua.png").buildNormalizedPath.toStringz;
    auto font6 = (thisExePath().dirName ~ "/../resources/fonts/alpha_beta.png").buildNormalizedPath.toStringz;
    auto font7 = (thisExePath().dirName ~ "/../resources/fonts/jupiter_crash.png").buildNormalizedPath.toStringz;


    fonts[0] = LoadFont(font0); fonts[1] = LoadFont(font1);
    fonts[2] = LoadFont(font2); fonts[3] = LoadFont(font3);
    fonts[4] = LoadFont(font4); fonts[5] = LoadFont(font5);
    fonts[6] = LoadFont(font6); fonts[7] = LoadFont(font7);

    const string[MAX_FONTS] messages = [
        "ALAGARD FONT designed by Hewett Tsoi",
        "PIXELPLAY FONT designed by Aleksander Shevchuk",
        "MECHA FONT designed by Captain Falcon",
        "SETBACK FONT designed by Brian Kent (AEnigma)",
        "ROMULUS FONT designed by Hewett Tsoi",
        "PIXANTIQUA FONT designed by Gerhard Grossmann",
        "ALPHA_BETA FONT designed by Brian Kent (AEnigma)",
        "JUPITER_CRASH FONT designed by Brian Kent (AEnigma)"
    ];

    const int[MAX_FONTS] spacings = [ 2, 4, 8, 4, 3, 4, 4, 1 ];

    Vector2[MAX_FONTS] positions;

    for (int i = 0; i < MAX_FONTS; i++)
    {
        positions[i].x = screenWidth/2.0f - MeasureTextEx(fonts[i], messages[i].toStringz, fonts[i].baseSize*2.0f, cast(float)spacings[i]).x/2.0f;
        positions[i].y = 60.0f + fonts[i].baseSize + 45.0f*i;
    }

    // Small Y position corrections
    positions[3].y += 8;
    positions[4].y += 2;
    positions[7].y -= 8;

    Color[MAX_FONTS] colors = [
        Colors.MAROON,     Colors.ORANGE, Colors.DARKGREEN, Colors.DARKBLUE,
        Colors.DARKPURPLE, Colors.LIME,   Colors.GOLD,      Colors.RED
    ];

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

            DrawText("free fonts included with raylib", 250, 20, 20, Colors.DARKGRAY);
            DrawLine(220, 50, 590, 50, Colors.DARKGRAY);

            for (int i = 0; i < MAX_FONTS; i++)
            {
                DrawTextEx(fonts[i], messages[i].toStringz, positions[i], fonts[i].baseSize*2.0f, cast(float)spacings[i], colors[i]);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------

    // Fonts unloading
    for (int i = 0; i < MAX_FONTS; i++) {
        UnloadFont(fonts[i]);
    }

    CloseWindow();                 // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

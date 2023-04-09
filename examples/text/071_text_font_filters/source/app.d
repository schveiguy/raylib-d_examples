/*******************************************************************************************
*
*   raylib [text] example - Font filters
*
*   NOTE: After font loading, font texture atlas filter could be configured for a softer
*   display of the font when scaling it to different sizes, that way, it's not required
*   to generate multiple fonts at multiple sizes (as long as the scaling is not very different)
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.2
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

    InitWindow(screenWidth, screenHeight, "raylib [text] example - font filters");

    const string msg = "Loaded Font";

    // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

    // TTF Font loading with custom generation parameters
    auto file = (thisExePath().dirName ~ "/../resources/KAISG.ttf").buildNormalizedPath.toStringz;
    Font font = LoadFontEx(file, 96, null, 0);

    // Generate mipmap levels to use trilinear filtering
    // NOTE: On 2D drawing it won't be noticeable, it looks like FILTER_BILINEAR
    GenTextureMipmaps(&font.texture);

    float fontSize = cast(float)font.baseSize;
    Vector2 fontPosition = { 40.0f, screenHeight/2.0f - 80.0f };
    Vector2 textSize = { 0.0f, 0.0f };

    // Setup texture scaling filter
    SetTextureFilter(font.texture, TextureFilter.TEXTURE_FILTER_POINT);
    int currentFontFilter = 0;      // TEXTURE_FILTER_POINT

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        fontSize += GetMouseWheelMove()*4.0f;

        // Choose font texture filter method
        if (IsKeyPressed(KeyboardKey.KEY_ONE))
        {
            SetTextureFilter(font.texture, TextureFilter.TEXTURE_FILTER_POINT);
            currentFontFilter = 0;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_TWO))
        {
            SetTextureFilter(font.texture, TextureFilter.TEXTURE_FILTER_BILINEAR);
            currentFontFilter = 1;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_THREE))
        {
            // NOTE: Trilinear filter won't be noticed on 2D drawing
            SetTextureFilter(font.texture, TextureFilter.TEXTURE_FILTER_TRILINEAR);
            currentFontFilter = 2;
        }

        textSize = MeasureTextEx(font, msg.toStringz, fontSize, 0);

        if (IsKeyDown(KeyboardKey.KEY_LEFT)) {
            fontPosition.x -= 10;
        }
        else if (IsKeyDown(KeyboardKey.KEY_RIGHT)) {
            fontPosition.x += 10;
        }

        // Load a dropped TTF file dynamically (at current fontSize)
        if (IsFileDropped())
        {
            FilePathList droppedFiles = LoadDroppedFiles();

            // NOTE: We only support first ttf file dropped
            if (IsFileExtension(droppedFiles.paths[0], ".ttf"))
            {
                UnloadFont(font);
                font = LoadFontEx(droppedFiles.paths[0], cast(int)fontSize, null, 0);
            }

            UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawText("Use mouse wheel to change font size", 20, 20, 10, Colors.GRAY);
            DrawText("Use KEY_RIGHT and KEY_LEFT to move text", 20, 40, 10, Colors.GRAY);
            DrawText("Use 1, 2, 3 to change texture filter", 20, 60, 10, Colors.GRAY);
            DrawText("Drop a new TTF font for dynamic loading", 20, 80, 10, Colors.DARKGRAY);

            DrawTextEx(font, msg.toStringz, fontPosition, fontSize, 0, Colors.BLACK);

            // TODO: It seems texSize measurement is not accurate due to chars offsets...
            //DrawRectangleLines(fontPosition.x, fontPosition.y, textSize.x, textSize.y, RED);

            DrawRectangle(0, screenHeight - 80, screenWidth, 80, Colors.LIGHTGRAY);
            DrawText(TextFormat("Font size: %02.02f", fontSize), 20, screenHeight - 50, 10, Colors.DARKGRAY);
            DrawText(TextFormat("Text size: [%02.02f, %02.02f]", textSize.x, textSize.y), 20, screenHeight - 30, 10, Colors.DARKGRAY);
            DrawText("CURRENT TEXTURE FILTER:", 250, 400, 20, Colors.GRAY);

            if (currentFontFilter == 0) {
                DrawText("POINT", 570, 400, 20, Colors.BLACK);
            }
            else if (currentFontFilter == 1) {
                DrawText("BILINEAR", 570, 400, 20, Colors.BLACK);
            }
            else if (currentFontFilter == 2) {
                DrawText("TRILINEAR", 570, 400, 20, Colors.BLACK);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadFont(font);           // Font unloading

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

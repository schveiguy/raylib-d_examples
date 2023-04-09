/*******************************************************************************************
*
*   raylib [textures] example - Image loading and drawing on it
*
*   NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 1.4, last time updated with raylib 1.4
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2016-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image drawing");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    auto file1 = (thisExePath().dirName ~ "/../resources/cat.png").buildNormalizedPath.toStringz;
    Image cat = LoadImage(file1);             // Load image in CPU memory (RAM)
    ImageCrop(&cat, Rectangle( 100, 10, 280, 380 ));        // Crop an image piece
    ImageFlipHorizontal(&cat);                              // Flip cropped image horizontally
    ImageResize(&cat, 150, 200);                            // Resize flipped-cropped image

    auto file2 = (thisExePath().dirName ~ "/../resources/parrots.png").buildNormalizedPath.toStringz;
    Image parrots = LoadImage(file2);     // Load image in CPU memory (RAM)

    // Draw one image over the other with a scaling of 1.5f
    ImageDraw(&parrots, cat, Rectangle( 0, 0, cast(float)cat.width, cast(float)cat.height ), Rectangle( 30, 40, cat.width*1.5f, cat.height*1.5f ), Colors.WHITE);
    ImageCrop(&parrots, Rectangle( 0, 50, cast(float)parrots.width, cast(float)parrots.height - 100 )); // Crop resulting image

    // Draw on the image with a few image draw methods
    ImageDrawPixel(&parrots, 10, 10, Colors.RAYWHITE);
    ImageDrawCircleLines(&parrots, 10, 10, 5, Colors.RAYWHITE);
    ImageDrawRectangle(&parrots, 5, 20, 10, 10, Colors.RAYWHITE);

    UnloadImage(cat);       // Unload image from RAM

    // Load custom font for frawing on image
    auto file3 = (thisExePath().dirName ~ "/../resources/custom_jupiter_crash.png").buildNormalizedPath.toStringz;
    Font font = LoadFont(file3);

    // Draw over image using custom font
    ImageDrawTextEx(&parrots, font, "PARROTS & CAT", Vector2(300, 230), cast(float)font.baseSize, -2, Colors.WHITE);

    UnloadFont(font);       // Unload custom font (already drawn used on image)

    Texture2D texture = LoadTextureFromImage(parrots);      // Image converted to texture, uploaded to GPU memory (VRAM)
    UnloadImage(parrots);   // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

    SetTargetFPS(60);
    //---------------------------------------------------------------------------------------

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

            DrawTexture(texture, screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 40, Colors.WHITE);
            DrawRectangleLines(screenWidth/2 - texture.width/2, screenHeight/2 - texture.height/2 - 40, texture.width, texture.height, Colors.DARKGRAY);

            DrawText("We are drawing only one texture from various images composed!", 240, 350, 10, Colors.DARKGRAY);
            DrawText("Source images have been cropped, scaled, flipped and copied one over the other.", 190, 370, 10, Colors.DARKGRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

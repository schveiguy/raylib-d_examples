/*******************************************************************************************
*
*   raylib [textures] example - gif playing
*
*   Example originally created with raylib 4.2, last time updated with raylib 4.2
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;

const int MAX_FRAME_DELAY = 20;
const int MIN_FRAME_DELAY =  1;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - gif playing");

    int animFrames = 0;

    // Load all GIF animation frames into a single Image
    // NOTE: GIF data is always loaded as RGBA (32bit) by default
    // NOTE: Frames are just appended one after another in image.data memory
    auto file = (thisExePath().dirName ~ "/../resources/scarfy_run.gif").buildNormalizedPath.toStringz;
    Image imScarfyAnim = LoadImageAnim(file, &animFrames);

    // Load texture from image
    // NOTE: We will update this texture when required with next frame data
    // WARNING: It's not recommended to use this technique for sprites animation,
    // use spritesheets instead, like illustrated in textures_sprite_anim example
    Texture2D texScarfyAnim = LoadTextureFromImage(imScarfyAnim);

    uint nextFrameDataOffset = 0;   // Current byte offset to next frame in image.data

    int currentAnimFrame = 0;       // Current animation frame to load and draw
    int frameDelay = 8;             // Frame delay to switch between animation frames
    int frameCounter = 0;           // General frames counter

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        frameCounter++;
        if (frameCounter >= frameDelay)
        {
            // Move to next frame
            // NOTE: If final frame is reached we return to first frame
            currentAnimFrame++;
            if (currentAnimFrame >= animFrames) currentAnimFrame = 0;

            // Get memory offset position for next frame data in image.data
            nextFrameDataOffset = imScarfyAnim.width*imScarfyAnim.height*4*currentAnimFrame;

            // Update GPU texture data with next frame image data
            // WARNING: Data size (frame size) and pixel format must match already created texture
            UpdateTexture(texScarfyAnim, (cast(ubyte*)imScarfyAnim.data) + nextFrameDataOffset);

            frameCounter = 0;
        }

        // Control frames delay
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            frameDelay++;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            frameDelay--;
        }

        if (frameDelay > MAX_FRAME_DELAY) {
            frameDelay = MAX_FRAME_DELAY;
        }
        else if (frameDelay < MIN_FRAME_DELAY) {
            frameDelay = MIN_FRAME_DELAY;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawText(TextFormat("TOTAL GIF FRAMES:  %02i", animFrames), 50, 30, 20, Colors.LIGHTGRAY);
            DrawText(TextFormat("CURRENT FRAME: %02i", currentAnimFrame), 50, 60, 20, Colors.GRAY);
            DrawText(TextFormat("CURRENT FRAME IMAGE.DATA OFFSET: %02i", nextFrameDataOffset), 50, 90, 20, Colors.GRAY);

            DrawText("FRAMES DELAY: ", 100, 305, 10, Colors.DARKGRAY);
            DrawText(TextFormat("%02i frames", frameDelay), 620, 305, 10, Colors.DARKGRAY);
            DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 350, 10, Colors.DARKGRAY);

            for (int i = 0; i < MAX_FRAME_DELAY; i++)
            {
                if (i < frameDelay) DrawRectangle(190 + 21*i, 300, 20, 20, Colors.RED);
                DrawRectangleLines(190 + 21*i, 300, 20, 20, Colors.MAROON);
            }

            DrawTexture(texScarfyAnim, GetScreenWidth()/2 - texScarfyAnim.width/2, 140, Colors.WHITE);

            DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texScarfyAnim);   // Unload texture
    UnloadImage(imScarfyAnim);      // Unload image (contains all frames)

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

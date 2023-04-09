/*******************************************************************************************
*
*   raylib [textures] example - Sprite animation
*
*   Example originally created with raylib 1.3, last time updated with raylib 1.3
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

const int MAX_FRAME_SPEED = 15;
const int MIN_FRAME_SPEED =  1;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [texture] example - sprite anim");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
    auto file = (thisExePath().dirName ~ "/../resources/scarfy.png").buildNormalizedPath.toStringz;
    Texture2D scarfy = LoadTexture(file);        // Texture loading

    Vector2 position = { 350.0f, 280.0f };
    Rectangle frameRec = { 0.0f, 0.0f, cast(float)scarfy.width/6, cast(float)scarfy.height };
    int currentFrame = 0;

    int framesCounter = 0;
    int framesSpeed = 8;            // Number of spritesheet frames shown by second

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        framesCounter++;

        if (framesCounter >= (60/framesSpeed))
        {
            framesCounter = 0;
            currentFrame++;

            if (currentFrame > 5) currentFrame = 0;

            frameRec.x = cast(float)currentFrame * cast(float)scarfy.width/6;
        }

        // Control frames speed
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            framesSpeed++;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            framesSpeed--;
        }

        if (framesSpeed > MAX_FRAME_SPEED) {
            framesSpeed = MAX_FRAME_SPEED;
        }
        else if (framesSpeed < MIN_FRAME_SPEED) {
            framesSpeed = MIN_FRAME_SPEED;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawTexture(scarfy, 15, 40, Colors.WHITE);
            DrawRectangleLines(15, 40, scarfy.width, scarfy.height, Colors.LIME);
            DrawRectangleLines(
                15 + cast(int)frameRec.x,
                40 + cast(int)frameRec.y,
                cast(int)frameRec.width,
                cast(int)frameRec.height,
                Colors.RED
            );

            DrawText("FRAME SPEED: ", 165, 210, 10, Colors.DARKGRAY);
            DrawText(TextFormat("%02i FPS", framesSpeed), 575, 210, 10, Colors.DARKGRAY);
            DrawText("PRESS RIGHT/LEFT KEYS to CHANGE SPEED!", 290, 240, 10, Colors.DARKGRAY);

            for (int i = 0; i < MAX_FRAME_SPEED; i++)
            {
                if (i < framesSpeed) {
                    DrawRectangle(250 + 21*i, 205, 20, 20, Colors.RED);
                }
                DrawRectangleLines(250 + 21*i, 205, 20, 20, Colors.MAROON);
            }

            DrawTextureRec(scarfy, frameRec, position, Colors.WHITE);  // Draw part of the texture

            DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(scarfy);       // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

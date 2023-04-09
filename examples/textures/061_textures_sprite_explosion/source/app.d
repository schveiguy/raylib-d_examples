/*******************************************************************************************
*
*   raylib [textures] example - sprite explosion
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Anata and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;

const int NUM_FRAMES_PER_LINE = 5;
const int NUM_LINES           = 5;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - sprite explosion");

    InitAudioDevice();

    // Load explosion sound
    auto file1 = (thisExePath().dirName ~ "/../resources/boom.wav").buildNormalizedPath.toStringz;
    Sound fxBoom = LoadSound(file1);

    // Load explosion texture
    auto file2 = (thisExePath().dirName ~ "/../resources/explosion.png").buildNormalizedPath.toStringz;
    Texture2D explosion = LoadTexture(file2);

    // Init variables for animation
    float frameWidth = cast(float)(explosion.width/NUM_FRAMES_PER_LINE);   // Sprite one frame rectangle width
    float frameHeight = cast(float)(explosion.height/NUM_LINES);           // Sprite one frame rectangle height
    int currentFrame = 0;
    int currentLine = 0;

    Rectangle frameRec = { 0, 0, frameWidth, frameHeight };
    Vector2 position = { 0.0f, 0.0f };

    bool active = false;
    int framesCounter = 0;

    SetTargetFPS(120);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        // Check for mouse button pressed and activate explosion (if not active)
        if (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT) && !active)
        {
            position = GetMousePosition();
            active = true;

            position.x -= frameWidth/2.0f;
            position.y -= frameHeight/2.0f;

            PlaySound(fxBoom);
        }

        // Compute explosion animation frames
        if (active)
        {
            framesCounter++;

            if (framesCounter > 2)
            {
                currentFrame++;

                if (currentFrame >= NUM_FRAMES_PER_LINE)
                {
                    currentFrame = 0;
                    currentLine++;

                    if (currentLine >= NUM_LINES)
                    {
                        currentLine = 0;
                        active = false;
                    }
                }

                framesCounter = 0;
            }
        }

        frameRec.x = frameWidth*currentFrame;
        frameRec.y = frameHeight*currentLine;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            // Draw explosion required frame rectangle
            if (active) {
                DrawTextureRec(explosion, frameRec, position, Colors.WHITE);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(explosion);   // Unload texture
    UnloadSound(fxBoom);        // Unload sound

    CloseAudioDevice();

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

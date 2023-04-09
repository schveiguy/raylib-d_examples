/*******************************************************************************************
*
*   raylib [textures] example - Bunnymark
*
*   Example originally created with raylib 1.6, last time updated with raylib 2.5
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

import core.stdc.stdlib; // Required for: malloc(), free()

const int MAX_BUNNIES  =  50000;    // 50K bunnies limit

// This is the maximum amount of elements (quads) per batch
// NOTE: This value is defined in [rlgl] module and can be changed there
const int MAX_BATCH_ELEMENTS = 8192;

struct Bunny {
    Vector2 position;
    Vector2 speed;
    Color color;
}

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - bunnymark");

    // Load bunny texture
    auto file = (thisExePath().dirName ~ "/../resources/wabbit_alpha.png").buildNormalizedPath.toStringz;
    Texture2D texBunny = LoadTexture(file);

    Bunny *bunnies = cast(Bunny*)malloc(MAX_BUNNIES*Bunny.sizeof);    // Bunnies array

    int bunniesCount = 0;           // Bunnies counter

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT))
        {
            // Create more bunnies
            for (int i = 0; i < 100; i++)
            {
                if (bunniesCount < MAX_BUNNIES)
                {
                    bunnies[bunniesCount].position = GetMousePosition();
                    bunnies[bunniesCount].speed.x = cast(float)GetRandomValue(-250, 250)/60.0f;
                    bunnies[bunniesCount].speed.y = cast(float)GetRandomValue(-250, 250)/60.0f;
                    bunnies[bunniesCount].color = Color( cast(ubyte)GetRandomValue(50, 240),
                                                         cast(ubyte)GetRandomValue(80, 240),
                                                         cast(ubyte)GetRandomValue(100, 240),
                                                         255 );
                    bunniesCount++;
                }
            }
        }

        // Update bunnies
        for (int i = 0; i < bunniesCount; i++)
        {
            bunnies[i].position.x += bunnies[i].speed.x;
            bunnies[i].position.y += bunnies[i].speed.y;

            if (((bunnies[i].position.x + texBunny.width/2) > GetScreenWidth())
                || ((bunnies[i].position.x + texBunny.width/2) < 0)) {
                bunnies[i].speed.x *= -1;
            }
            if (((bunnies[i].position.y + texBunny.height/2) > GetScreenHeight())
                || ((bunnies[i].position.y + texBunny.height/2 - 40) < 0)) {
                bunnies[i].speed.y *= -1;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            for (int i = 0; i < bunniesCount; i++)
            {
                // NOTE: When internal batch buffer limit is reached (MAX_BATCH_ELEMENTS),
                // a draw call is launched and buffer starts being filled again;
                // before issuing a draw call, updated vertex data from internal CPU buffer is send to GPU...
                // Process of sending data is costly and it could happen that GPU data has not been completely
                // processed for drawing while new data is tried to be sent (updating current in-use buffers)
                // it could generates a stall and consequently a frame drop, limiting the number of drawn bunnies
                DrawTexture(texBunny, cast(int)bunnies[i].position.x, cast(int)bunnies[i].position.y, bunnies[i].color);
            }

            DrawRectangle(0, 0, screenWidth, 40, Colors.BLACK);
            DrawText(TextFormat("bunnies: %i", bunniesCount), 120, 10, 20, Colors.GREEN);
            DrawText(TextFormat("batched draw calls: %i", 1 + bunniesCount/MAX_BATCH_ELEMENTS), 320, 10, 20, Colors.MAROON);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    free(bunnies);              // Unload bunnies data array

    UnloadTexture(texBunny);    // Unload bunny texture

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

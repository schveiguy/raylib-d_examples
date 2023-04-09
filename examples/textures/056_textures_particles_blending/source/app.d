/*******************************************************************************************
*
*   raylib example - particles blending
*
*   Example originally created with raylib 1.7, last time updated with raylib 3.5
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

const int MAX_PARTICLES = 200;

// Particle structure with basic data
struct Particle {
    Vector2 position;
    Color color;
    float alpha;
    float size;
    float rotation;
    bool active;        // NOTE: Use it to activate/deactive particle
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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - particles blending");

    // Particles pool, reuse them!
    Particle[MAX_PARTICLES] mouseTail;

    // Initialize particles
    for (int i = 0; i < MAX_PARTICLES; i++)
    {
        mouseTail[i].position = Vector2( 0, 0 );
        mouseTail[i].color = Color( cast(ubyte)GetRandomValue(0, 255), cast(ubyte)GetRandomValue(0, 255), cast(ubyte)GetRandomValue(0, 255), 255 );
        mouseTail[i].alpha = 1.0f;
        mouseTail[i].size = cast(float)GetRandomValue(1, 30)/20.0f;
        mouseTail[i].rotation = cast(float)GetRandomValue(0, 360);
        mouseTail[i].active = false;
    }

    float gravity = 3.0f;

    auto file = (thisExePath().dirName ~ "/../resources/spark_flame.png").buildNormalizedPath.toStringz;
    Texture2D smoke = LoadTexture(file);

    int blending = BlendMode.BLEND_ALPHA;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        // Activate one particle every frame and Update active particles
        // NOTE: Particles initial position should be mouse position when activated
        // NOTE: Particles fall down with gravity and rotation... and disappear after 2 seconds (alpha = 0)
        // NOTE: When a particle disappears, active = false and it can be reused.
        for (int i = 0; i < MAX_PARTICLES; i++)
        {
            if (!mouseTail[i].active)
            {
                mouseTail[i].active = true;
                mouseTail[i].alpha = 1.0f;
                mouseTail[i].position = GetMousePosition();
                i = MAX_PARTICLES;
            }
        }

        for (int i = 0; i < MAX_PARTICLES; i++)
        {
            if (mouseTail[i].active)
            {
                mouseTail[i].position.y += gravity/2;
                mouseTail[i].alpha -= 0.005f;

                if (mouseTail[i].alpha <= 0.0f) mouseTail[i].active = false;

                mouseTail[i].rotation += 2.0f;
            }
        }

        if (IsKeyPressed(KeyboardKey.KEY_SPACE))
        {
            if (blending == BlendMode.BLEND_ALPHA) {
                blending = BlendMode.BLEND_ADDITIVE;
            }
            else {
                blending = BlendMode.BLEND_ALPHA;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.DARKGRAY);

            BeginBlendMode(blending);

                // Draw active particles
                for (int i = 0; i < MAX_PARTICLES; i++)
                {
                    if (mouseTail[i].active) {
                        DrawTexturePro(
                            smoke,
                            Rectangle( 0.0f, 0.0f, cast(float)smoke.width, cast(float)smoke.height ),
                            Rectangle(
                                mouseTail[i].position.x,
                                mouseTail[i].position.y,
                                smoke.width*mouseTail[i].size,
                                smoke.height*mouseTail[i].size
                            ),
                            Vector2(
                                cast(float)(smoke.width*mouseTail[i].size/2.0f),
                                cast(float)(smoke.height*mouseTail[i].size/2.0f)
                            ),
                            mouseTail[i].rotation,
                            Fade(mouseTail[i].color, mouseTail[i].alpha)
                        );
                    }
                }

            EndBlendMode();

            DrawText("PRESS SPACE to CHANGE BLENDING MODE", 180, 20, 20, Colors.BLACK);

            if (blending == BlendMode.BLEND_ALPHA) {
                DrawText("ALPHA BLENDING", 290, screenHeight - 40, 20, Colors.BLACK);
            }
            else {
                DrawText("ADDITIVE BLENDING", 280, screenHeight - 40, 20, Colors.RAYWHITE);
            }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(smoke);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

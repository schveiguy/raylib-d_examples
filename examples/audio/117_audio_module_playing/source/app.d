/*******************************************************************************************
*
*   raylib [audio] example - Module playing (streaming)
*
*   Example originally created with raylib 1.5, last time updated with raylib 3.5
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

const int MAX_CIRCLES = 64;

struct CircleWave {
    Vector2 position;
    float radius;
    float alpha;
    float speed;
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

    SetConfigFlags(ConfigFlags.FLAG_MSAA_4X_HINT);  // NOTE: Try to enable MSAA 4X

    InitWindow(screenWidth, screenHeight, "raylib [audio] example - module playing (streaming)");

    InitAudioDevice();                  // Initialize audio device

    Color[14] colors = [
        Colors.ORANGE, Colors.RED,    Colors.GOLD,  Colors.LIME,
        Colors.BLUE,   Colors.VIOLET, Colors.BROWN, Colors.LIGHTGRAY,
        Colors.PINK,   Colors.YELLOW, Colors.GREEN, Colors.SKYBLUE,
        Colors.PURPLE, Colors.BEIGE
    ];

    // Creates some circles for visual effect
    CircleWave[MAX_CIRCLES] circles;

    for (int i = MAX_CIRCLES - 1; i >= 0; i--)
    {
        circles[i].alpha = 0.0f;
        circles[i].radius = cast(float)GetRandomValue(10, 40);
        circles[i].position.x = cast(float)GetRandomValue(cast(int)circles[i].radius, cast(int)(screenWidth - circles[i].radius));
        circles[i].position.y = cast(float)GetRandomValue(cast(int)circles[i].radius, cast(int)(screenHeight - circles[i].radius));
        circles[i].speed = cast(float)GetRandomValue(1, 100)/2000.0f;
        circles[i].color = colors[GetRandomValue(0, 13)];
    }

    auto file = (thisExePath().dirName ~ "/../resources/mini1111.xm").buildNormalizedPath.toStringz;
    Music music = LoadMusicStream(file);
    music.looping = false;
    float pitch = 1.0f;

    PlayMusicStream(music);

    float timePlayed = 0.0f;
    bool pause = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateMusicStream(music);      // Update music buffer with new stream data

        // Restart music playing (stop and play)
        if (IsKeyPressed(KeyboardKey.KEY_SPACE))
        {
            StopMusicStream(music);
            PlayMusicStream(music);
        }

        // Pause/Resume music playing
        if (IsKeyPressed(KeyboardKey.KEY_P))
        {
            pause = !pause;

            if (pause) {
                PauseMusicStream(music);
            }
            else {
                ResumeMusicStream(music);
            }
        }

        if (IsKeyDown(KeyboardKey.KEY_DOWN)) {
            pitch -= 0.01f;
        }
        else if (IsKeyDown(KeyboardKey.KEY_UP)) {
            pitch += 0.01f;
        }

        SetMusicPitch(music, pitch);

        // Get timePlayed scaled to bar dimensions
        timePlayed = GetMusicTimePlayed(music)/GetMusicTimeLength(music)*(screenWidth - 40);

        // Color circles animation
        for (int i = MAX_CIRCLES - 1; (i >= 0) && !pause; i--)
        {
            circles[i].alpha += circles[i].speed;
            circles[i].radius += circles[i].speed*10.0f;

            if (circles[i].alpha > 1.0f) circles[i].speed *= -1;

            if (circles[i].alpha <= 0.0f)
            {
                circles[i].alpha = 0.0f;
                circles[i].radius = cast(float)GetRandomValue(10, 40);
                circles[i].position.x = cast(float)GetRandomValue(cast(int)circles[i].radius, cast(int)(screenWidth - circles[i].radius));
                circles[i].position.y = cast(float)GetRandomValue(cast(int)circles[i].radius, cast(int)(screenHeight - circles[i].radius));
                circles[i].color = colors[GetRandomValue(0, 13)];
                circles[i].speed = cast(float)GetRandomValue(1, 100)/2000.0f;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            for (int i = MAX_CIRCLES - 1; i >= 0; i--)
            {
                DrawCircleV(circles[i].position, circles[i].radius, Fade(circles[i].color, circles[i].alpha));
            }

            // Draw time bar
            DrawRectangle(20, screenHeight - 20 - 12, screenWidth - 40, 12, Colors.LIGHTGRAY);
            DrawRectangle(20, screenHeight - 20 - 12, cast(int)timePlayed, 12, Colors.MAROON);
            DrawRectangleLines(20, screenHeight - 20 - 12, screenWidth - 40, 12, Colors.GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadMusicStream(music);          // Unload music stream buffers from RAM

    CloseAudioDevice();     // Close audio device (music streaming is automatically stopped)

    CloseWindow();          // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

/*******************************************************************************************
*
*   raylib [shaders] example - Texture Waves
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Anata (@anatagawa) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Anata (@anatagawa) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;
import std.conv : to;

//version(DESKTOP) {
version(all) {
    const int GLSL_VERSION = 330;
}
else {   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    const int GLSL_VERSION = 100;
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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - texture waves");

    // Load texture texture to apply shaders
    auto file1 = (thisExePath().dirName ~ "/../resources/space.png").buildNormalizedPath.toStringz;
    Texture2D texture = LoadTexture(file1);

    // Load shader and setup location points and values
    auto fs = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/wave.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shader = LoadShader(null, fs);

    int secondsLoc = GetShaderLocation(shader, "secondes");
    int freqXLoc = GetShaderLocation(shader, "freqX");
    int freqYLoc = GetShaderLocation(shader, "freqY");
    int ampXLoc = GetShaderLocation(shader, "ampX");
    int ampYLoc = GetShaderLocation(shader, "ampY");
    int speedXLoc = GetShaderLocation(shader, "speedX");
    int speedYLoc = GetShaderLocation(shader, "speedY");

    // Shader uniform values that can be updated at any time
    float freqX = 25.0f;
    float freqY = 25.0f;
    float ampX = 5.0f;
    float ampY = 5.0f;
    float speedX = 8.0f;
    float speedY = 8.0f;

    float[2] screenSize = [ cast(float)GetScreenWidth(), cast(float)GetScreenHeight() ];

    SetShaderValue(shader, GetShaderLocation(shader, "size"), &screenSize[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, freqXLoc, &freqX, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, freqYLoc, &freqY, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, ampXLoc, &ampX, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, ampYLoc, &ampY, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, speedXLoc, &speedX, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, speedYLoc, &speedY, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);

    float seconds = 0.0f;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    // -------------------------------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        seconds += GetFrameTime();

        SetShaderValue(shader, secondsLoc, &seconds, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginShaderMode(shader);

                DrawTexture(texture, 0, 0, Colors.WHITE);
                DrawTexture(texture, texture.width, 0, Colors.WHITE);

            EndShaderMode();

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);         // Unload shader
    UnloadTexture(texture);       // Unload texture

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

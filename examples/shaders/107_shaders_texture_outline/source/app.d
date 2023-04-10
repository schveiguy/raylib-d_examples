/*******************************************************************************************
*
*   raylib [shaders] example - Apply an shdrOutline to a texture
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   Example originally created with raylib 4.0, last time updated with raylib 4.0
*
*   Example contributed by Samuel Skiff (@GoldenThumbs) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2021-2023 Samuel SKiff (@GoldenThumbs) and Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - Apply an outline to a texture");

    auto file1 = (thisExePath().dirName ~ "/../resources/fudesumi.png").buildNormalizedPath.toStringz;
    Texture2D texture = LoadTexture(file1);

    auto fs = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/outline.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shdrOutline = LoadShader(null, fs);

    float outlineSize = 5.0f;
    float[4] outlineColor = [ 1.0f, 0.0f, 0.0f, 1.0f ];     // Normalized RED color
    float[2] textureSize = [ cast(float)texture.width, cast(float)texture.height ];

    // Get shader locations
    int outlineSizeLoc = GetShaderLocation(shdrOutline, "outlineSize");
    int outlineColorLoc = GetShaderLocation(shdrOutline, "outlineColor");
    int textureSizeLoc = GetShaderLocation(shdrOutline, "textureSize");

    // Set shader values (they can be changed later)
    SetShaderValue(shdrOutline, outlineSizeLoc, &outlineSize, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shdrOutline, outlineColorLoc, &outlineColor[0], ShaderUniformDataType.SHADER_UNIFORM_VEC4);
    SetShaderValue(shdrOutline, textureSizeLoc, &textureSize[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        outlineSize += GetMouseWheelMove();
        if (outlineSize < 1.0f) {
            outlineSize = 1.0f;
        }

        SetShaderValue(shdrOutline, outlineSizeLoc, &outlineSize, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginShaderMode(shdrOutline);

                DrawTexture(texture, GetScreenWidth()/2 - texture.width/2, -30, Colors.WHITE);

            EndShaderMode();

            DrawText("Shader-based\ntexture\noutline", 10, 10, 20, Colors.GRAY);

            DrawText(TextFormat("Outline size: %i px", cast(int)outlineSize), 10, 120, 20, Colors.MAROON);

            DrawText("[ Use Mousewheel to change ]", 10, 145, 10, Colors.BLACK);

            DrawFPS(710, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);
    UnloadShader(shdrOutline);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

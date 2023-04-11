/*******************************************************************************************
*
*   raylib [shaders] example - Multiple sample2D with default batch system
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 3.5, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2020-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib - multiple sample2D");

    Image imRed = GenImageColor(800, 450, Color( 255, 0, 0, 255 ));
    Texture texRed = LoadTextureFromImage(imRed);
    UnloadImage(imRed);

    Image imBlue = GenImageColor(800, 450, Color( 0, 0, 255, 255 ));
    Texture texBlue = LoadTextureFromImage(imBlue);
    UnloadImage(imBlue);

    auto fs = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/color_mix.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shader = LoadShader(null, fs);

    // Get an additional sampler2D location to be enabled on drawing
    int texBlueLoc = GetShaderLocation(shader, "texture1");

    // Get shader uniform for divider
    int dividerLoc = GetShaderLocation(shader, "divider");
    float dividerValue = 0.5f;

    SetTargetFPS(60);                           // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())                // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        if (IsKeyDown(KeyboardKey.KEY_RIGHT)) {
            dividerValue += 0.01f;
        }
        else if (IsKeyDown(KeyboardKey.KEY_LEFT)) {
            dividerValue -= 0.01f;
        }

        if (dividerValue < 0.0f) {
            dividerValue = 0.0f;
        }
        else if (dividerValue > 1.0f) {
            dividerValue = 1.0f;
        }

        SetShaderValue(shader, dividerLoc, &dividerValue, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginShaderMode(shader);

                // WARNING: Additional samplers are enabled for all draw calls in the batch,
                // EndShaderMode() forces batch drawing and consequently resets active textures
                // to let other sampler2D to be activated on consequent drawings (if required)
                SetShaderValueTexture(shader, texBlueLoc, texBlue);

                // We are drawing texRed using default sampler2D texture0 but
                // an additional texture units is enabled for texBlue (sampler2D texture1)
                DrawTexture(texRed, 0, 0, Colors.WHITE);

            EndShaderMode();

            DrawText("Use KEY_LEFT/KEY_RIGHT to move texture mixing in shader!", 80, GetScreenHeight() - 40, 20, Colors.RAYWHITE);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);       // Unload shader
    UnloadTexture(texRed);      // Unload texture
    UnloadTexture(texBlue);     // Unload texture

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

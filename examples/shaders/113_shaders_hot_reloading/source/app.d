/*******************************************************************************************
*
*   raylib [shaders] example - Hot reloading
*
*   NOTE: This example requires raylib OpenGL 3.3 for shaders support and only #version 330
*         is currently supported. OpenGL ES 2.0 platforms are not supported at the moment.
*
*   Example originally created with raylib 3.0, last time updated with raylib 3.5
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
import core.stdc.time : asctime, localtime, time_t;

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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - hot reloading");

    auto fragShaderFileName = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/reload.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    time_t fragShaderFileModTime = GetFileModTime(fragShaderFileName);

    // Load raymarching shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    Shader shader = LoadShader(null, fragShaderFileName);

    // Get shader locations for required uniforms
    int resolutionLoc = GetShaderLocation(shader, "resolution");
    int mouseLoc = GetShaderLocation(shader, "mouse");
    int timeLoc = GetShaderLocation(shader, "time");

    float[2] resolution = [ cast(float)screenWidth, cast(float)screenHeight ];
    SetShaderValue(shader, resolutionLoc, &resolution[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

    float totalTime = 0.0f;
    bool shaderAutoReloading = false;

    SetTargetFPS(60);                       // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())            // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        totalTime += GetFrameTime();
        Vector2 mouse = GetMousePosition();
        float[2] mousePos = [ mouse.x, mouse.y ];

        // Set shader required uniform values
        SetShaderValue(shader, timeLoc, &totalTime, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
        SetShaderValue(shader, mouseLoc, &mousePos[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

        // Hot shader reloading
        if (shaderAutoReloading || (IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)))
        {
            long currentFragShaderModTime = GetFileModTime(fragShaderFileName);

            // Check if shader file has been modified
            if (currentFragShaderModTime != fragShaderFileModTime)
            {
                // Try reloading updated shader
                Shader updatedShader = LoadShader(null, fragShaderFileName);

                if (updatedShader.id != rlGetShaderIdDefault())      // It was correctly loaded
                {
                    UnloadShader(shader);
                    shader = updatedShader;

                    // Get shader locations for required uniforms
                    resolutionLoc = GetShaderLocation(shader, "resolution");
                    mouseLoc = GetShaderLocation(shader, "mouse");
                    timeLoc = GetShaderLocation(shader, "time");

                    // Reset required uniforms
                    SetShaderValue(shader, resolutionLoc, &resolution[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);
                }

                fragShaderFileModTime = currentFragShaderModTime;
            }
        }

        if (IsKeyPressed(KeyboardKey.KEY_A)) {
            shaderAutoReloading = !shaderAutoReloading;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            // We only draw a white full-screen rectangle, frame is generated in shader
            BeginShaderMode(shader);
                DrawRectangle(0, 0, screenWidth, screenHeight, Colors.WHITE);
            EndShaderMode();

            DrawText(
                TextFormat("PRESS [A] to TOGGLE SHADER AUTOLOADING: %s",
                    shaderAutoReloading ? "AUTO".toStringz : "MANUAL".toStringz),
                10, 10, 10,
                shaderAutoReloading ? Colors.RED : Colors.BLACK
            );
            if (!shaderAutoReloading) {
                DrawText("MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, Colors.BLACK);
            }

            DrawText(TextFormat("Shader last modification: %s", asctime(localtime(&fragShaderFileModTime))), 10, 430, 10, Colors.BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);           // Unload shader

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

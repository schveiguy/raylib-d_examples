/*******************************************************************************************
*
*   raylib [shaders] example - Sieve of Eratosthenes
*
*   NOTE: Sieve of Eratosthenes, the earliest known (ancient Greek) prime number sieve.
*
*       "Sift the twos and sift the threes,
*        The Sieve of Eratosthenes.
*        When the multiples sublime,
*        the numbers that are left are prime."
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by ProfJski and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 ProfJski and Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - Sieve of Eratosthenes");

    RenderTexture2D target = LoadRenderTexture(screenWidth, screenHeight);

    // Load Eratosthenes shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    auto fs = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/eratosthenes.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shader = LoadShader(null, fs);

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Nothing to do here, everything is happening in the shader
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);       // Enable drawing to texture
            ClearBackground(Colors.BLACK);     // Clear the render texture

            // Draw a rectangle in shader mode to be used as shader canvas
            // NOTE: Rectangle uses font white character texture coordinates,
            // so shader can not be applied here directly because input vertexTexCoord
            // do not represent full screen coordinates (space where want to apply shader)
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Colors.BLACK);
        EndTextureMode();               // End drawing to texture (now we have a blank texture available for the shader)

        BeginDrawing();
            ClearBackground(Colors.RAYWHITE);  // Clear screen background

            BeginShaderMode(shader);
                // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
                DrawTextureRec(
                    target.texture,
                    Rectangle( 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height ),
                    Vector2( 0.0f, 0.0f ),
                    Colors.WHITE
                );
            EndShaderMode();
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(shader);               // Unload shader
    UnloadRenderTexture(target);        // Unload render texture

    CloseWindow();                      // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

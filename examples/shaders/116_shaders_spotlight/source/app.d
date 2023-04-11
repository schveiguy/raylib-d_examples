/*******************************************************************************************
*
*   raylib [shaders] example - Simple shader mask
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.7
*
*   Example contributed by Chris Camacho (@chriscamacho) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Chris Camacho (@chriscamacho) and Ramon Santamaria (@raysan5)
*
********************************************************************************************
*
*   The shader makes alpha holes in the forground to give the appearance of a top
*   down look at a spotlight casting a pool of light...
*
*   The right hand side of the screen there is just enough light to see whats
*   going on without the spot light, great for a stealth type game where you
*   have to avoid the spotlights.
*
*   The left hand side of the screen is in pitch dark except for where the spotlights are.
*
*   Although this example doesn't scale like the letterbox example, you could integrate
*   the two techniques, but by scaling the actual colour of the render texture rather
*   than using alpha as a mask.
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;
import std.conv : to;

import std.math;

//version(DESKTOP) {
version(all) {
    const int GLSL_VERSION = 330;
}
else {   // PLATFORM_RPI, PLATFORM_ANDROID, PLATFORM_WEB
    const int GLSL_VERSION = 100;
}

const int MAX_SPOTS      =   3;        // NOTE: It must be the same as define in shader
const int MAX_STARS      = 400;

// Spot data
struct Spot {
    Vector2 position;
    Vector2 speed;
    float inner;
    float radius;

    // Shader locations
    uint positionLoc;
    uint innerLoc;
    uint radiusLoc;
}

// Stars in the star field have a position and velocity
struct Star {
    Vector2 position;
    Vector2 speed;
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

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - shader spotlight");
    HideCursor();

    auto file1 = (thisExePath().dirName ~ "/../resources/raysan.png").buildNormalizedPath.toStringz;
    Texture texRay = LoadTexture(file1);

    Star[MAX_STARS] stars;

    for (int n = 0; n < MAX_STARS; n++) {
        ResetStar(&stars[n]);
    }

    // Progress all the stars on, so they don't all start in the centre
    for (int m = 0; m < screenWidth/2.0; m++)
    {
        for (int n = 0; n < MAX_STARS; n++) {
            UpdateStar(&stars[n]);
        }
    }

    int frameCounter = 0;

    // Use default vert shader
    auto fs = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/spotlight.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shdrSpot = LoadShader(null, fs);

    // Get the locations of spots in the shader
    Spot[MAX_SPOTS] spots;

    for (int i = 0; i < MAX_SPOTS; i++)
    {
        auto posName = ("spots[" ~ i.to!string ~ "].pos\0").toStringz;
        auto innerName = ("spots[" ~ i.to!string ~ "].inner\0").toStringz;
        auto radiusName = ("spots[" ~ i.to!string ~ "].radius\0").toStringz;

        spots[i].positionLoc = GetShaderLocation(shdrSpot, posName);
        spots[i].innerLoc = GetShaderLocation(shdrSpot, innerName);
        spots[i].radiusLoc = GetShaderLocation(shdrSpot, radiusName);
    }

    // Tell the shader how wide the screen is so we can have
    // a pitch black half and a dimly lit half.
    uint wLoc = GetShaderLocation(shdrSpot, "screenWidth");
    float sw = cast(float)GetScreenWidth();
    SetShaderValue(shdrSpot, wLoc, &sw, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);

    // Randomize the locations and velocities of the spotlights
    // and initialize the shader locations
    for (int i = 0; i < MAX_SPOTS; i++)
    {
        spots[i].position.x = cast(float)GetRandomValue(64, screenWidth - 64);
        spots[i].position.y = cast(float)GetRandomValue(64, screenHeight - 64);
        spots[i].speed = Vector2( 0, 0 );

        while ((fabs(spots[i].speed.x) + fabs(spots[i].speed.y)) < 2)
        {
            spots[i].speed.x = GetRandomValue(-400, 40) / 100.0f; // / 10.0f
            spots[i].speed.y = GetRandomValue(-400, 40) / 100.0f; // / 10.0f
        }

        spots[i].inner = 28.0f * (i + 1);
        spots[i].radius = 48.0f * (i + 1);

        SetShaderValue(shdrSpot, spots[i].positionLoc, &spots[i].position.x, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
        SetShaderValue(shdrSpot, spots[i].innerLoc, &spots[i].inner, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
        SetShaderValue(shdrSpot, spots[i].radiusLoc, &spots[i].radius, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    }

    SetTargetFPS(60);               // Set  to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        frameCounter++;

        // Move the stars, resetting them if the go offscreen
        for (int n = 0; n < MAX_STARS; n++) {
            UpdateStar(&stars[n]);
        }

        // Update the spots, send them to the shader
        for (int i = 0; i < MAX_SPOTS; i++)
        {
            if (i == 0)
            {
                Vector2 mp = GetMousePosition();
                spots[i].position.x = mp.x;
                spots[i].position.y = screenHeight - mp.y;
            }
            else
            {
                spots[i].position.x += spots[i].speed.x;
                spots[i].position.y += spots[i].speed.y;

                if (spots[i].position.x < 64) {
                    spots[i].speed.x = -spots[i].speed.x;
                }
                if (spots[i].position.x > (screenWidth - 64)) {
                    spots[i].speed.x = -spots[i].speed.x;
                }
                if (spots[i].position.y < 64) {
                    spots[i].speed.y = -spots[i].speed.y;
                }
                if (spots[i].position.y > (screenHeight - 64)) {
                    spots[i].speed.y = -spots[i].speed.y;
                }
            }

            SetShaderValue(shdrSpot, spots[i].positionLoc, &spots[i].position.x, ShaderUniformDataType.SHADER_UNIFORM_VEC2);
        }

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.DARKBLUE);

            // Draw stars and bobs
            for (int n = 0; n < MAX_STARS; n++)
            {
                // Single pixel is just too small these days!
                DrawRectangle(cast(int)stars[n].position.x, cast(int)stars[n].position.y, 2, 2, Colors.WHITE);
            }

            for (int i = 0; i < 16; i++)
            {
                DrawTexture(texRay,
                    cast(int)((screenWidth/2.0f) + cos((frameCounter + i*8)/51.45f)*(screenWidth/2.2f) - 32),
                    cast(int)((screenHeight/2.0f) + sin((frameCounter + i*8)/17.87f)*(screenHeight/4.2f)), Colors.WHITE);
            }

            // Draw spot lights
            BeginShaderMode(shdrSpot);
                // Instead of a blank rectangle you could render here
                // a render texture of the full screen used to do screen
                // scaling (slight adjustment to shader would be required
                // to actually pay attention to the colour!)
                DrawRectangle(0, 0, screenWidth, screenHeight, Colors.WHITE);
            EndShaderMode();

            DrawFPS(10, 10);

            DrawText("Move the mouse!", 10, 30, 20, Colors.GREEN);
            DrawText("Pitch Black", cast(int)(screenWidth*0.2f), screenHeight/2, 20, Colors.GREEN);
            DrawText("Dark", cast(int)(screenWidth*.66f), screenHeight/2, 20, Colors.GREEN);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texRay);
    UnloadShader(shdrSpot);

    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}


static void ResetStar(Star *s)
{
    s.position = Vector2( GetScreenWidth()/2.0f, GetScreenHeight()/2.0f );

    do
    {
        s.speed.x = cast(float)GetRandomValue(-1000, 1000)/100.0f;
        s.speed.y = cast(float)GetRandomValue(-1000, 1000)/100.0f;

    } while (!(fabs(s.speed.x) + (fabs(s.speed.y) > 1)));

    s.position = Vector2Add(s.position, Vector2Multiply(s.speed, Vector2( 8.0f, 8.0f )));
}

static void UpdateStar(Star *s)
{
    s.position = Vector2Add(s.position, s.speed);

    if ((s.position.x < 0) || (s.position.x > GetScreenWidth()) ||
        (s.position.y < 0) || (s.position.y > GetScreenHeight()))
    {
        ResetStar(s);
    }
}

/*******************************************************************************************
*
*   raylib [shaders] example - Julia sets
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3).
*
*   Example originally created with raylib 2.5, last time updated with raylib 4.0
*
*   Example contributed by eggmund (@eggmund) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 eggmund (@eggmund) and Ramon Santamaria (@raysan5)
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

// A few good julia sets
const float[2][6] pointsOfInterest =
[
    [ -0.348827f, 0.607167f ],
    [ -0.786268f, 0.169728f ],
    [ -0.8f     , 0.156f    ],
    [ 0.285f    , 0.0f      ],
    [ -0.835f   , -0.2321f  ],
    [ -0.70176f , -0.3842f  ],
];

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    //SetConfigFlags(FLAG_WINDOW_HIGHDPI);
    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - julia sets");

    // Load julia set shader
    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    auto fs = (thisExePath().dirName ~ "/../resources/shaders/" ~
                TextFormat("glsl%i/julia_set.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shader = LoadShader(null, fs);

    // Create a RenderTexture2D to be used for render to texture
    RenderTexture2D target = LoadRenderTexture(GetScreenWidth(), GetScreenHeight());

    // c constant to use in z^2 + c
    float[2] c = [ pointsOfInterest[0][0], pointsOfInterest[0][1] ];

    // Offset and zoom to draw the julia set at. (centered on screen and default size)
    float[2] offset = [ -cast(float)GetScreenWidth()/2, -cast(float)GetScreenHeight()/2 ];
    float zoom = 1.0f;

    Vector2 offsetSpeed = { 0.0f, 0.0f };

    // Get variable (uniform) locations on the shader to connect with the program
    // NOTE: If uniform variable could not be found in the shader, function returns -1
    int cLoc = GetShaderLocation(shader, "c");
    int zoomLoc = GetShaderLocation(shader, "zoom");
    int offsetLoc = GetShaderLocation(shader, "offset");

    // Tell the shader what the screen dimensions, zoom, offset and c are
    float[2] screenDims = [ cast(float)GetScreenWidth(), cast(float)GetScreenHeight() ];
    SetShaderValue(shader, GetShaderLocation(shader, "screenDims"), &screenDims[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

    SetShaderValue(shader, cLoc, &c[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);
    SetShaderValue(shader, zoomLoc, &zoom, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
    SetShaderValue(shader, offsetLoc, &offset[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

    int incrementSpeed = 0;             // Multiplier of speed to change c value
    bool showControls = true;           // Show controls
    bool pause = false;                 // Pause animation

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        // Press [1 - 6] to reset c to a point of interest
        if (IsKeyPressed(KeyboardKey.KEY_ONE) ||
            IsKeyPressed(KeyboardKey.KEY_TWO) ||
            IsKeyPressed(KeyboardKey.KEY_THREE) ||
            IsKeyPressed(KeyboardKey.KEY_FOUR) ||
            IsKeyPressed(KeyboardKey.KEY_FIVE) ||
            IsKeyPressed(KeyboardKey.KEY_SIX))
        {
            if (IsKeyPressed(KeyboardKey.KEY_ONE))        c[0] = pointsOfInterest[0][0], c[1] = pointsOfInterest[0][1];
            else if (IsKeyPressed(KeyboardKey.KEY_TWO))   c[0] = pointsOfInterest[1][0], c[1] = pointsOfInterest[1][1];
            else if (IsKeyPressed(KeyboardKey.KEY_THREE)) c[0] = pointsOfInterest[2][0], c[1] = pointsOfInterest[2][1];
            else if (IsKeyPressed(KeyboardKey.KEY_FOUR))  c[0] = pointsOfInterest[3][0], c[1] = pointsOfInterest[3][1];
            else if (IsKeyPressed(KeyboardKey.KEY_FIVE))  c[0] = pointsOfInterest[4][0], c[1] = pointsOfInterest[4][1];
            else if (IsKeyPressed(KeyboardKey.KEY_SIX))   c[0] = pointsOfInterest[5][0], c[1] = pointsOfInterest[5][1];

            SetShaderValue(shader, cLoc, &c[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

            zoom = 1.0f;
            SetShaderValue(shader, zoomLoc, &zoom, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
            offset[0] = -cast(float)GetScreenWidth()/2;
            offset[1] = -cast(float)GetScreenHeight()/2;
            SetShaderValue(shader, offsetLoc, &offset[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);
        }

        if (IsKeyPressed(KeyboardKey.KEY_SPACE)) {
            pause = !pause;                 // Pause animation (c change)
        }
        if (IsKeyPressed(KeyboardKey.KEY_F1)) {
            showControls = !showControls;  // Toggle whether or not to show controls
        }

        if (!pause)
        {
            if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
                incrementSpeed++;
            }
            else if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
                incrementSpeed--;
            }

            // TODO: The idea is to zoom and move around with mouse
            // Probably offset movement should be proportional to zoom level
            if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT) || IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT))
            {
                if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT)) {
                    zoom += zoom*0.003f;
                }
                if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)) {
                    zoom -= zoom*0.003f;
                }

                Vector2 mousePos = GetMousePosition();

                offsetSpeed.x = mousePos.x - (cast(float)screenWidth/2);
                offsetSpeed.y = mousePos.y - (cast(float)screenHeight/2);

                // Slowly move camera to targetOffset
                offset[0] += GetFrameTime()*offsetSpeed.x*0.8f;
                offset[1] += GetFrameTime()*offsetSpeed.y*0.8f;
            }
            else {
                offsetSpeed = Vector2(0.0f, 0.0f);
            }

            SetShaderValue(shader, zoomLoc, &zoom, ShaderUniformDataType.SHADER_UNIFORM_FLOAT);
            SetShaderValue(shader, offsetLoc, &offset[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);

            // Increment c value with time
            float amount = GetFrameTime()*incrementSpeed*0.0005f;
            c[0] += amount;
            c[1] += amount;

            SetShaderValue(shader, cLoc, &c[0], ShaderUniformDataType.SHADER_UNIFORM_VEC2);
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        // Using a render texture to draw Julia set
        BeginTextureMode(target);       // Enable drawing to texture
            ClearBackground(Colors.BLACK);     // Clear the render texture

            // Draw a rectangle in shader mode to be used as shader canvas
            // NOTE: Rectangle uses font white character texture coordinates,
            // so shader can not be applied here directly because input vertexTexCoord
            // do not represent full screen coordinates (space where want to apply shader)
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Colors.BLACK);
        EndTextureMode();

        BeginDrawing();
            ClearBackground(Colors.BLACK);     // Clear screen background

            // Draw the saved texture and rendered julia set with shader
            // NOTE: We do not invert texture on Y, already considered inside shader
            BeginShaderMode(shader);
                // WARNING: If FLAG_WINDOW_HIGHDPI is enabled, HighDPI monitor scaling should be considered
                // when rendering the RenderTexture2D to fit in the HighDPI scaled Window
                DrawTextureEx(target.texture, Vector2( 0.0f, 0.0f ), 0.0f, 1.0f, Colors.WHITE);
            EndShaderMode();

            if (showControls)
            {
                DrawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, Colors.RAYWHITE);
                DrawText("Press KEY_F1 to toggle these controls", 10, 30, 10, Colors.RAYWHITE);
                DrawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, Colors.RAYWHITE);
                DrawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, Colors.RAYWHITE);
                DrawText("Press KEY_SPACE to pause movement animation", 10, 75, 10, Colors.RAYWHITE);
            }
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

/*******************************************************************************************
*
*   raylib [shaders] example - Apply a postprocessing shader to a scene
*
*   NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
*         OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.
*
*   NOTE: Shaders used in this example are #version 330 (OpenGL 3.3), to test this example
*         on OpenGL ES 2.0 platforms (Android, Raspberry Pi, HTML5), use #version 100 shaders
*         raylib comes with shaders ready for both versions, check raylib/shaders install folder
*
*   Example originally created with raylib 1.3, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
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

const int MAX_POSTPRO_SHADERS = 12;


enum PostproShader {
    FX_GRAYSCALE = 0,
    FX_POSTERIZATION,
    FX_DREAM_VISION,
    FX_PIXELIZER,
    FX_CROSS_HATCHING,
    FX_CROSS_STITCHING,
    FX_PREDATOR_VIEW,
    FX_SCANLINES,
    FX_FISHEYE,
    FX_SOBEL,
    FX_BLOOM,
    FX_BLUR
}

string[] postproShaderText = [
    "GRAYSCALE",
    "POSTERIZATION",
    "DREAM_VISION",
    "PIXELIZER",
    "CROSS_HATCHING",
    "CROSS_STITCHING",
    "PREDATOR_VIEW",
    "SCANLINES",
    "FISHEYE",
    "SOBEL",
    "BLOOM",
    "BLUR"
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

    SetConfigFlags(ConfigFlags.FLAG_MSAA_4X_HINT);      // Enable Multi Sampling Anti Aliasing 4x (if available)

    InitWindow(screenWidth, screenHeight, "raylib [shaders] example - postprocessing shader");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 2.0f, 2.0f, 2.0f );           // Camera position
    camera.target = Vector3( 0.0f, 1.0f, 0.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    string resourcesDir = (thisExePath().dirName ~ "/../resources").buildNormalizedPath;

    auto file1 = (resourcesDir ~ "/models/church.obj").toStringz;
    Model model = LoadModel(file1);                 // Load OBJ model

    auto file2 = (resourcesDir ~ "/models/church_diffuse.png").toStringz;
    Texture2D texture = LoadTexture(file2); // Load model texture (diffuse map)

    model.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = texture;        // Set model diffuse texture

    Vector3 position = { 0.0f, 0.0f, 0.0f };            // Set model position

    // Load all postpro shaders
    // NOTE 1: All postpro shader use the base vertex shader (DEFAULT_VERTEX_SHADER)
    // NOTE 2: We load the correct shader depending on GLSL version
    Shader[MAX_POSTPRO_SHADERS] shaders;

    auto fsDir = (thisExePath().dirName ~ "/../resources/shaders/" ~
            TextFormat("glsl%i", GLSL_VERSION).to!string).buildNormalizedPath;

    // NOTE: Defining 0 (NULL) for vertex shader forces usage of internal default vertex shader
    shaders[PostproShader.FX_GRAYSCALE]       = LoadShader(null, (fsDir ~ "/grayscale.fs").toStringz);
    shaders[PostproShader.FX_POSTERIZATION]   = LoadShader(null, (fsDir ~ "/posterization.fs").toStringz);
    shaders[PostproShader.FX_DREAM_VISION]    = LoadShader(null, (fsDir ~ "/dream_vision.fs").toStringz);
    shaders[PostproShader.FX_PIXELIZER]       = LoadShader(null, (fsDir ~ "/pixelizer.fs").toStringz);
    shaders[PostproShader.FX_CROSS_HATCHING]  = LoadShader(null, (fsDir ~ "/cross_hatching.fs").toStringz);
    shaders[PostproShader.FX_CROSS_STITCHING] = LoadShader(null, (fsDir ~ "/cross_stitching.fs").toStringz);
    shaders[PostproShader.FX_PREDATOR_VIEW]   = LoadShader(null, (fsDir ~ "/predator.fs").toStringz);
    shaders[PostproShader.FX_SCANLINES]       = LoadShader(null, (fsDir ~ "/scanlines.fs").toStringz);
    shaders[PostproShader.FX_FISHEYE]         = LoadShader(null, (fsDir ~ "/fisheye.fs").toStringz);
    shaders[PostproShader.FX_SOBEL]           = LoadShader(null, (fsDir ~ "/sobel.fs").toStringz);
    shaders[PostproShader.FX_BLOOM]           = LoadShader(null, (fsDir ~ "/bloom.fs").toStringz);
    shaders[PostproShader.FX_BLUR]            = LoadShader(null, (fsDir ~ "/blur.fs").toStringz);

    int currentShader = PostproShader.FX_GRAYSCALE;

    // Create a RenderTexture2D to be used for render to texture
    RenderTexture2D target = LoadRenderTexture(screenWidth, screenHeight);

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_ORBITAL);

        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            currentShader++;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            currentShader--;
        }

        if (currentShader >= MAX_POSTPRO_SHADERS) {
            currentShader = 0;
        }
        else if (currentShader < 0) {
            currentShader = MAX_POSTPRO_SHADERS - 1;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginTextureMode(target);       // Enable drawing to texture
            ClearBackground(Colors.RAYWHITE);  // Clear texture background

            BeginMode3D(camera);        // Begin 3d mode drawing
                DrawModel(model, position, 0.1f, Colors.WHITE);   // Draw 3d model with texture
                DrawGrid(10, 1.0f);     // Draw a grid
            EndMode3D();                // End 3d mode drawing, returns to orthographic 2d mode
        EndTextureMode();               // End drawing to texture (now we have a texture available for next passes)

        BeginDrawing();
            ClearBackground(Colors.RAYWHITE);  // Clear screen background

            // Render generated texture using selected postprocessing shader
            BeginShaderMode(shaders[currentShader]);
                // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
                DrawTextureRec(
                    target.texture,
                    Rectangle( 0, 0, cast(float)target.texture.width, cast(float)-target.texture.height ),
                    Vector2( 0, 0 ),
                    Colors.WHITE
                );
            EndShaderMode();

            // Draw 2d shapes and text over drawn texture
            DrawRectangle(0, 9, 580, 30, Fade(Colors.LIGHTGRAY, 0.7f));

            DrawText("(c) Church 3D model by Alberto Cano", screenWidth - 200, screenHeight - 20, 10, Colors.GRAY);
            DrawText("CURRENT POSTPRO SHADER:", 10, 15, 20, Colors.BLACK);
            DrawText(postproShaderText[currentShader].toStringz, 330, 15, 20, Colors.RED);
            DrawText("< >", 540, 10, 30, Colors.DARKBLUE);
            DrawFPS(700, 15);
        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    // Unload all postpro shaders
    for (int i = 0; i < MAX_POSTPRO_SHADERS; i++) {
        UnloadShader(shaders[i]);
    }

    UnloadTexture(texture);         // Unload texture
    UnloadModel(model);             // Unload model
    UnloadRenderTexture(target);    // Unload render texture

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

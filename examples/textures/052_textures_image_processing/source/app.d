/*******************************************************************************************
*
*   raylib [textures] example - Image processing
*
*   NOTE: Images are loaded in CPU memory (RAM); textures are loaded in GPU memory (VRAM)
*
*   Example originally created with raylib 1.4, last time updated with raylib 3.5
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

const int NUM_PROCESSES = 9;

enum ImageProcess {
    NONE = 0,
    COLOR_GRAYSCALE,
    COLOR_TINT,
    COLOR_INVERT,
    COLOR_CONTRAST,
    COLOR_BRIGHTNESS,
    GAUSSIAN_BLUR,
    FLIP_VERTICAL,
    FLIP_HORIZONTAL
}

string[] processText = [
    "NO PROCESSING",
    "COLOR GRAYSCALE",
    "COLOR TINT",
    "COLOR INVERT",
    "COLOR CONTRAST",
    "COLOR BRIGHTNESS",
    "GAUSSIAN BLUR",
    "FLIP VERTICAL",
    "FLIP HORIZONTAL"
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

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - image processing");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    auto file = (thisExePath().dirName ~ "/../resources/parrots.png").buildNormalizedPath.toStringz;
    Image imOrigin = LoadImage(file);   // Loaded in CPU memory (RAM)
    ImageFormat(&imOrigin, PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);         // Format image to RGBA 32bit (required for texture update) <-- ISSUE
    Texture2D texture = LoadTextureFromImage(imOrigin);    // Image converted to texture, GPU memory (VRAM)

    Image imCopy = ImageCopy(imOrigin);

    int currentProcess = ImageProcess.NONE;
    bool textureReload = false;

    Rectangle[NUM_PROCESSES] toggleRecs;
    int mouseHoverRec = -1;

    for (int i = 0; i < NUM_PROCESSES; i++) {
        toggleRecs[i] = Rectangle( 40.0f, cast(float)(50 + 32*i), 150.0f, 30.0f );
    }

    SetTargetFPS(60);
    //---------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        // Mouse toggle group logic
        for (int i = 0; i < NUM_PROCESSES; i++)
        {
            if (CheckCollisionPointRec(GetMousePosition(), toggleRecs[i]))
            {
                mouseHoverRec = i;

                if (IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_LEFT))
                {
                    currentProcess = i;
                    textureReload = true;
                }
                break;
            }
            else mouseHoverRec = -1;
        }

        // Keyboard toggle group logic
        if (IsKeyPressed(KeyboardKey.KEY_DOWN))
        {
            currentProcess++;
            if (currentProcess > (NUM_PROCESSES - 1)) currentProcess = 0;
            textureReload = true;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_UP))
        {
            currentProcess--;
            if (currentProcess < 0) currentProcess = 7;
            textureReload = true;
        }

        // Reload texture when required
        if (textureReload)
        {
            UnloadImage(imCopy);                // Unload image-copy data
            imCopy = ImageCopy(imOrigin);     // Restore image-copy from image-origin

            // NOTE: Image processing is a costly CPU process to be done every frame,
            // If image processing is required in a frame-basis, it should be done
            // with a texture and by shaders
            switch (currentProcess)
            {
                case ImageProcess.COLOR_GRAYSCALE: ImageColorGrayscale(&imCopy); break;
                case ImageProcess.COLOR_TINT: ImageColorTint(&imCopy, Colors.GREEN); break;
                case ImageProcess.COLOR_INVERT: ImageColorInvert(&imCopy); break;
                case ImageProcess.COLOR_CONTRAST: ImageColorContrast(&imCopy, -40); break;
                case ImageProcess.COLOR_BRIGHTNESS: ImageColorBrightness(&imCopy, -80); break;
                case ImageProcess.GAUSSIAN_BLUR: ImageBlurGaussian(&imCopy, 10); break;
                case ImageProcess.FLIP_VERTICAL: ImageFlipVertical(&imCopy); break;
                case ImageProcess.FLIP_HORIZONTAL: ImageFlipHorizontal(&imCopy); break;
                default: break;
            }

            Color *pixels = LoadImageColors(imCopy);    // Load pixel data from image (RGBA 32bit)
            UpdateTexture(texture, pixels);             // Update texture with new image data
            UnloadImageColors(pixels);                  // Unload pixels data from RAM

            textureReload = false;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            DrawText("IMAGE PROCESSING:", 40, 30, 10, Colors.DARKGRAY);

            // Draw rectangles
            for (int i = 0; i < NUM_PROCESSES; i++)
            {
                DrawRectangleRec(toggleRecs[i], ((i == currentProcess) || (i == mouseHoverRec)) ? Colors.SKYBLUE : Colors.LIGHTGRAY);
                DrawRectangleLines(
                    cast(int)toggleRecs[i].x,
                    cast(int) toggleRecs[i].y,
                    cast(int) toggleRecs[i].width,
                    cast(int) toggleRecs[i].height,
                    ((i == currentProcess) || (i == mouseHoverRec)) ? Colors.BLUE : Colors.GRAY
                );
                DrawText(
                    processText[i].toStringz,
                    cast(int)( toggleRecs[i].x + toggleRecs[i].width/2 - MeasureText(processText[i].toStringz, 10)/2),
                    cast(int)toggleRecs[i].y + 11, 10,
                    ((i == currentProcess) || (i == mouseHoverRec)) ? Colors.DARKBLUE : Colors.DARKGRAY
                );
            }

            DrawTexture(texture, screenWidth - texture.width - 60, screenHeight/2 - texture.height/2, Colors.WHITE);
            DrawRectangleLines(screenWidth - texture.width - 60, screenHeight/2 - texture.height/2, texture.width, texture.height, Colors.BLACK);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(texture);       // Unload texture from VRAM
    UnloadImage(imOrigin);        // Unload image-origin from RAM
    UnloadImage(imCopy);          // Unload image-copy from RAM

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

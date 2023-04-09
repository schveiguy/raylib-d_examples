/*******************************************************************************************
*
*   raylib [textures] example - Mouse painting
*
*   Example originally created with raylib 3.0, last time updated with raylib 3.0
*
*   Example contributed by Chris Dill (@MysteriousSpace) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2023 Chris Dill (@MysteriousSpace) and Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

import std.path : dirName, buildNormalizedPath;
import std.file : thisExePath;
import std.string : toStringz;

const int MAX_COLORS_COUNT = 23;          // Number of colors available

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] example - mouse painting");

    // Colors to choose from
    Color[MAX_COLORS_COUNT] colors = [
        Colors.RAYWHITE, Colors.YELLOW,    Colors.GOLD,      Colors.ORANGE,
        Colors.PINK,     Colors.RED,       Colors.MAROON,    Colors.GREEN,
        Colors.LIME,     Colors.DARKGREEN, Colors.SKYBLUE,   Colors.BLUE,
        Colors.DARKBLUE, Colors.PURPLE,    Colors.VIOLET,    Colors.DARKPURPLE,
        Colors.BEIGE,    Colors.BROWN,     Colors.DARKBROWN, Colors.LIGHTGRAY,
        Colors.GRAY,     Colors.DARKGRAY,  Colors.BLACK
    ];

    // Define colorsRecs data (for every rectangle)
    Rectangle[MAX_COLORS_COUNT] colorsRecs;

    for (int i = 0; i < MAX_COLORS_COUNT; i++)
    {
        colorsRecs[i].x = 10 + 30.0f*i + 2*i;
        colorsRecs[i].y = 10;
        colorsRecs[i].width = 30;
        colorsRecs[i].height = 30;
    }

    int colorSelected = 0;
    int colorSelectedPrev = colorSelected;
    int colorMouseHover = 0;
    float brushSize = 20.0f;
    bool mouseWasPressed = false;

    Rectangle btnSaveRec = { 750, 10, 40, 30 };
    bool btnSaveMouseHover = false;
    bool showSaveMessage = false;
    int saveMessageCounter = 0;

    // Create a RenderTexture2D to use as a canvas
    RenderTexture2D target = LoadRenderTexture(screenWidth, screenHeight);

    // Clear render texture before entering the game loop
    BeginTextureMode(target);
    ClearBackground(colors[0]);
    EndTextureMode();

    SetTargetFPS(120);              // Set our game to run at 120 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        Vector2 mousePos = GetMousePosition();

        // Move between colors with keys
        if (IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
            colorSelected++;
        }
        else if (IsKeyPressed(KeyboardKey.KEY_LEFT)) {
            colorSelected--;
        }

        if (colorSelected >= MAX_COLORS_COUNT) {
            colorSelected = MAX_COLORS_COUNT - 1;
        }
        else if (colorSelected < 0) {
            colorSelected = 0;
        }

        // Choose color with mouse
        for (int i = 0; i < MAX_COLORS_COUNT; i++)
        {
            if (CheckCollisionPointRec(mousePos, colorsRecs[i]))
            {
                colorMouseHover = i;
                break;
            }
            else colorMouseHover = -1;
        }

        if ((colorMouseHover >= 0) && IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT))
        {
            colorSelected = colorMouseHover;
            colorSelectedPrev = colorSelected;
        }

        // Change brush size
        brushSize += GetMouseWheelMove()*5;
        if (brushSize < 2) brushSize = 2;
        if (brushSize > 50) brushSize = 50;

        if (IsKeyPressed(KeyboardKey.KEY_C))
        {
            // Clear render texture to clear color
            BeginTextureMode(target);
            ClearBackground(colors[0]);
            EndTextureMode();
        }

        if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_LEFT) || (GetGestureDetected() == Gesture.GESTURE_DRAG))
        {
            // Paint circle into render texture
            // NOTE: To avoid discontinuous circles, we could store
            // previous-next mouse points and just draw a line using brush size
            BeginTextureMode(target);
            if (mousePos.y > 50) {
                DrawCircle(cast(int)mousePos.x, cast(int)mousePos.y, brushSize, colors[colorSelected]);
            }
            EndTextureMode();
        }

        if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT))
        {
            if (!mouseWasPressed)
            {
                colorSelectedPrev = colorSelected;
                colorSelected = 0;
            }

            mouseWasPressed = true;

            // Erase circle from render texture
            BeginTextureMode(target);
            if (mousePos.y > 50) {
                DrawCircle(cast(int)mousePos.x, cast(int)mousePos.y, brushSize, colors[0]);
            }
            EndTextureMode();
        }
        else if (IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_RIGHT) && mouseWasPressed)
        {
            colorSelected = colorSelectedPrev;
            mouseWasPressed = false;
        }

        // Check mouse hover save button
        if (CheckCollisionPointRec(mousePos, btnSaveRec)) btnSaveMouseHover = true;
        else btnSaveMouseHover = false;

        // Image saving logic
        // NOTE: Saving painted texture to a default named image
        if ((btnSaveMouseHover && IsMouseButtonReleased(MouseButton.MOUSE_BUTTON_LEFT)) || IsKeyPressed(KeyboardKey.KEY_S))
        {
            Image image = LoadImageFromTexture(target.texture);
            ImageFlipVertical(&image);
            auto file = (thisExePath().dirName ~ "/my_amazing_texture_painting.png").buildNormalizedPath.toStringz;
            ExportImage(image, file);
            UnloadImage(image);
            showSaveMessage = true;
        }

        if (showSaveMessage)
        {
            // On saving, show a full screen message for 2 seconds
            saveMessageCounter++;
            if (saveMessageCounter > 240)
            {
                showSaveMessage = false;
                saveMessageCounter = 0;
            }
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

        ClearBackground(Colors.RAYWHITE);

        // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
        DrawTextureRec(
            target.texture,
            Rectangle(0, 0, cast(float)target.texture.width, cast(float)-target.texture.height ),
            Vector2( 0, 0 ),
            Colors.WHITE
        );

        // Draw drawing circle for reference
        if (mousePos.y > 50)
        {
            if (IsMouseButtonDown(MouseButton.MOUSE_BUTTON_RIGHT)) {
                DrawCircleLines(cast(int)mousePos.x, cast(int)mousePos.y, brushSize, Colors.GRAY);
            }
            else {
                DrawCircle(GetMouseX(), GetMouseY(), brushSize, colors[colorSelected]);
            }
        }

        // Draw top panel
        DrawRectangle(0, 0, GetScreenWidth(), 50, Colors.RAYWHITE);
        DrawLine(0, 50, GetScreenWidth(), 50, Colors.LIGHTGRAY);

        // Draw color selection rectangles
        for (int i = 0; i < MAX_COLORS_COUNT; i++) DrawRectangleRec(colorsRecs[i], colors[i]);
        DrawRectangleLines(10, 10, 30, 30, Colors.LIGHTGRAY);

        if (colorMouseHover >= 0) {
            DrawRectangleRec(colorsRecs[colorMouseHover], Fade(Colors.WHITE, 0.6f));
        }

        DrawRectangleLinesEx(
            Rectangle(
                colorsRecs[colorSelected].x - 2,
                colorsRecs[colorSelected].y - 2,
                colorsRecs[colorSelected].width + 4,
                colorsRecs[colorSelected].height + 4
            ),
            2,
            Colors.BLACK
        );

        // Draw save image button
        DrawRectangleLinesEx(btnSaveRec, 2, btnSaveMouseHover ? Colors.RED : Colors.BLACK);
        DrawText("SAVE!", 755, 20, 10, btnSaveMouseHover ? Colors.RED : Colors.BLACK);

        // Draw save image message
        if (showSaveMessage)
        {
            DrawRectangle(0, 0, GetScreenWidth(), GetScreenHeight(), Fade(Colors.RAYWHITE, 0.8f));
            DrawRectangle(0, 150, GetScreenWidth(), 80, Colors.BLACK);
            DrawText("IMAGE SAVED:  my_amazing_texture_painting.png", 150, 180, 20, Colors.RAYWHITE);
        }

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadRenderTexture(target);    // Unload render texture

    CloseWindow();                  // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

/*******************************************************************************************
*
*   raylib [models] example - Detect basic 3d collisions (box vs sphere vs box)
*
*   Example originally created with raylib 1.3, last time updated with raylib 3.5
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2015-2023 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

import raylib;

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
void main()
{
    // Initialization
    //--------------------------------------------------------------------------------------
    const int screenWidth = 800;
    const int screenHeight = 450;

    InitWindow(screenWidth, screenHeight, "raylib [models] example - box collisions");

    // Define the camera to look into our 3d world
    Camera camera = {
        Vector3( 0.0f, 10.0f, 10.0f ),
        Vector3( 0.0f, 0.0f, 0.0f ),
        Vector3( 0.0f, 1.0f, 0.0f ),
        45.0f,
        0
    };

    Vector3 playerPosition = { 0.0f, 1.0f, 2.0f };
    Vector3 playerSize = { 1.0f, 2.01f, 1.0f };
    Color playerColor = Colors.GREEN;

    Vector3 enemyBoxPos = { -4.0f, 1.0f, 0.0f };
    Vector3 enemyBoxSize = { 2.0f, 2.0f, 2.0f };

    Vector3 enemySpherePos = { 4.0f, 0.0f, 0.0f };
    float enemySphereSize = 1.5f;

    bool collision = false;

    SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        // Move player
        if (IsKeyDown(KeyboardKey.KEY_RIGHT))     playerPosition.x += 0.2f;
        else if (IsKeyDown(KeyboardKey.KEY_LEFT)) playerPosition.x -= 0.2f;
        else if (IsKeyDown(KeyboardKey.KEY_DOWN)) playerPosition.z += 0.2f;
        else if (IsKeyDown(KeyboardKey.KEY_UP))   playerPosition.z -= 0.2f;

        collision = false;

        // Check collisions player vs enemy-box
        if (CheckCollisionBoxes(
            BoundingBox(
                Vector3(
                    playerPosition.x - playerSize.x/2,
                    playerPosition.y - playerSize.y/2,
                    playerPosition.z - playerSize.z/2
                ),
                Vector3(
                    playerPosition.x + playerSize.x/2,
                    playerPosition.y + playerSize.y/2,
                    playerPosition.z + playerSize.z/2
                )
            ),
            BoundingBox(
                Vector3(
                    enemyBoxPos.x - enemyBoxSize.x/2,
                    enemyBoxPos.y - enemyBoxSize.y/2,
                    enemyBoxPos.z - enemyBoxSize.z/2
                ),
                Vector3(
                    enemyBoxPos.x + enemyBoxSize.x/2,
                    enemyBoxPos.y + enemyBoxSize.y/2,
                    enemyBoxPos.z + enemyBoxSize.z/2
                )
            )
        )) {
            collision = true;
        }

        // Check collisions player vs enemy-sphere
        if (CheckCollisionBoxSphere(
            BoundingBox(
                Vector3(
                    playerPosition.x - playerSize.x/2,
                    playerPosition.y - playerSize.y/2,
                    playerPosition.z - playerSize.z/2
                ),
                Vector3(
                    playerPosition.x + playerSize.x/2,
                    playerPosition.y + playerSize.y/2,
                    playerPosition.z + playerSize.z/2
                )
            ),
            enemySpherePos,
            enemySphereSize
        )) {
            collision = true;
        }

        if (collision) {
            playerColor = Colors.RED;
        }
        else {
            playerColor = Colors.GREEN;
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                // Draw enemy-box
                DrawCube(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, Colors.GRAY);
                DrawCubeWires(enemyBoxPos, enemyBoxSize.x, enemyBoxSize.y, enemyBoxSize.z, Colors.DARKGRAY);

                // Draw enemy-sphere
                DrawSphere(enemySpherePos, enemySphereSize, Colors.GRAY);
                DrawSphereWires(enemySpherePos, enemySphereSize, 16, 16, Colors.DARKGRAY);

                // Draw player
                DrawCubeV(playerPosition, playerSize, playerColor);

                DrawGrid(10, 1.0f);        // Draw a grid

            EndMode3D();

            DrawText("Move player with cursors to collide", 220, 40, 20, Colors.GRAY);

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

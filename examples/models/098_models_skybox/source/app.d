/*******************************************************************************************
*
*   raylib [models] example - Skybox loading and drawing
*
*   Example originally created with raylib 1.8, last time updated with raylib 4.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2017-2023 Ramon Santamaria (@raysan5)
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

    InitWindow(screenWidth, screenHeight, "raylib [models] example - skybox loading and drawing");

    // Define the camera to look into our 3d world
    Camera camera;
    camera.position = Vector3( 1.0f, 1.0f, 1.0f );           // Camera position
    camera.target = Vector3( 4.0f, 1.0f, 4.0f );             // Camera looking at point
    camera.up = Vector3( 0.0f, 1.0f, 0.0f );                 // Camera up vector (rotation towards target)
    camera.fovy = 45.0f;                                     // Camera field-of-view Y
    camera.projection = CameraProjection.CAMERA_PERSPECTIVE; // Camera projection type

    // Load skybox model
    Mesh cube = GenMeshCube(1.0f, 1.0f, 1.0f);
    Model skybox = LoadModelFromMesh(cube);

    bool useHDR = true;                                      // CHANGE THIS TO LOAD SKYBOX

    // Load skybox shader and set required locations
    // NOTE: Some locations are automatically set at shader loading
    auto vs1 = (thisExePath().dirName ~
                "/../resources/shaders/" ~
                TextFormat("glsl%i/skybox.vs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    auto fs1 = (thisExePath().dirName ~
                "/../resources/shaders/" ~
                TextFormat("glsl%i/skybox.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    skybox.materials[0].shader = LoadShader(vs1, fs1);

    int[1] int_arr;

    int_arr = MaterialMapIndex.MATERIAL_MAP_CUBEMAP;
    SetShaderValue(
        skybox.materials[0].shader,
        GetShaderLocation(skybox.materials[0].shader, "environmentMap"),
        &int_arr,
        ShaderUniformDataType.SHADER_UNIFORM_INT
    );

    int_arr = useHDR ? 1 : 0;
    SetShaderValue(
        skybox.materials[0].shader,
        GetShaderLocation(skybox.materials[0].shader, "doGamma"),
        &int_arr,
        ShaderUniformDataType.SHADER_UNIFORM_INT
    );

    int_arr = useHDR ? 1 : 0;
    SetShaderValue(
        skybox.materials[0].shader,
        GetShaderLocation(skybox.materials[0].shader, "vflipped"),
        &int_arr,
        ShaderUniformDataType.SHADER_UNIFORM_INT
    );

    // Load cubemap shader and setup required shader locations
    auto vs2 = (thisExePath().dirName ~
                "/../resources/shaders/" ~
                TextFormat("glsl%i/cubemap.vs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    auto fs2 = (thisExePath().dirName ~
                "/../resources/shaders/" ~
                TextFormat("glsl%i/cubemap.fs", GLSL_VERSION).to!string).buildNormalizedPath.toStringz;
    Shader shdrCubemap = LoadShader(vs2, fs2);

    int_arr = 0;
    SetShaderValue(
        shdrCubemap,
        GetShaderLocation(shdrCubemap, "equirectangularMap"),
        &int_arr,
        ShaderUniformDataType.SHADER_UNIFORM_INT
    );

    string skyboxFileName;

    Texture2D panorama;

    if (useHDR)
    {
        skyboxFileName = (thisExePath().dirName ~ "/../resources/dresden_square_2k.hdr").buildNormalizedPath;

        // Load HDR panorama (sphere) texture
        panorama = LoadTexture(skyboxFileName.toStringz);

        // Generate cubemap (texture with 6 quads-cube-mapping) from panorama HDR texture
        // NOTE 1: New texture is generated rendering to texture, shader calculates the sphere->cube coordinates mapping
        // NOTE 2: It seems on some Android devices WebGL, fbo does not properly support a FLOAT-based attachment,
        // despite texture can be successfully created.. so using PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 instead of PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture =
            GenTextureCubemap(shdrCubemap, panorama, 1024, PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);

        //UnloadTexture(panorama);    // Texture not required anymore, cubemap already generated
    }
    else
    {
        Image img = LoadImage(
            (thisExePath().dirName ~ "/../resources/skybox.png").buildNormalizedPath.toStringz
        );
        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture =
            LoadTextureCubemap(img, CubemapLayout.CUBEMAP_LAYOUT_AUTO_DETECT);    // CUBEMAP_LAYOUT_PANORAMA
        UnloadImage(img);
    }

    DisableCursor();                    // Limit cursor to relative movement inside the window

    SetTargetFPS(60);                   // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!WindowShouldClose())        // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        UpdateCamera(&camera, CameraMode.CAMERA_FIRST_PERSON);

        // Load new cubemap texture on drag&drop
        if (IsFileDropped())
        {
            FilePathList droppedFiles = LoadDroppedFiles();

            if (droppedFiles.count == 1)         // Only support one file dropped
            {
                if (IsFileExtension(droppedFiles.paths[0], ".png;.jpg;.hdr;.bmp;.tga"))
                {
                    // Unload current cubemap texture and load new one
                    UnloadTexture(skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture);
                    if (useHDR)
                    {
                        Texture2D panorama2 = LoadTexture(droppedFiles.paths[0]);

                        // Generate cubemap from panorama texture
                        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture =
                            GenTextureCubemap(shdrCubemap, panorama2, 1024, PixelFormat.PIXELFORMAT_UNCOMPRESSED_R8G8B8A8);
                        UnloadTexture(panorama2);
                    }
                    else
                    {
                        Image img = LoadImage(droppedFiles.paths[0]);
                        skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture =
                            LoadTextureCubemap(img, CubemapLayout.CUBEMAP_LAYOUT_AUTO_DETECT);
                        UnloadImage(img);
                    }

                    skyboxFileName = droppedFiles.paths[0].to!string;
                }
            }

            UnloadDroppedFiles(droppedFiles);    // Unload filepaths from memory
        }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(Colors.RAYWHITE);

            BeginMode3D(camera);

                // We are inside the cube, we need to disable backface culling!
                rlDisableBackfaceCulling();
                rlDisableDepthMask();
                    DrawModel(skybox, Vector3(0, 0, 0), 1.0f, Colors.WHITE);
                rlEnableBackfaceCulling();
                rlEnableDepthMask();

                DrawGrid(10, 1.0f);

            EndMode3D();

            //DrawTextureEx(panorama, (Vector2){ 0, 0 }, 0.0f, 0.5f, WHITE);

            if (useHDR) {
                DrawText(
                    TextFormat("Panorama image from hdrihaven.com: %s", GetFileName(skyboxFileName.toStringz)),
                    10,
                    GetScreenHeight() - 20, 10,
                    Colors.BLACK
                );
            }
            else {
                DrawText(
                    TextFormat(": %s", GetFileName(skyboxFileName.toStringz)),
                    10,
                    GetScreenHeight() - 20, 10,
                    Colors.BLACK
                );
            }

            DrawFPS(10, 10);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadShader(skybox.materials[0].shader);
    UnloadTexture(skybox.materials[0].maps[MaterialMapIndex.MATERIAL_MAP_CUBEMAP].texture);

    UnloadModel(skybox);        // Unload skybox model

    CloseWindow();              // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}

// Generate cubemap texture from HDR texture
static TextureCubemap GenTextureCubemap(Shader shader, Texture2D panorama, int size, int format)
{
    TextureCubemap cubemap = { 0 };

    rlDisableBackfaceCulling();     // Disable backface culling to render inside the cube

    // STEP 1: Setup framebuffer
    //------------------------------------------------------------------------------------------
    uint rbo = rlLoadTextureDepth(size, size, true);
    cubemap.id = rlLoadTextureCubemap(null, size, format);

    uint fbo = rlLoadFramebuffer(size, size);
    rlFramebufferAttach(
        fbo,
        rbo,
        rlFramebufferAttachType.RL_ATTACHMENT_DEPTH,
        rlFramebufferAttachTextureType.RL_ATTACHMENT_RENDERBUFFER,
        0
    );

    rlFramebufferAttach(
        fbo,
        cubemap.id,
        rlFramebufferAttachType.RL_ATTACHMENT_COLOR_CHANNEL0,
        rlFramebufferAttachTextureType.RL_ATTACHMENT_CUBEMAP_POSITIVE_X,
        0
    );

    // Check if framebuffer is complete with attachments (valid)
    if (rlFramebufferComplete(fbo)) {
        TraceLog(TraceLogLevel.LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", fbo);
    }
    //------------------------------------------------------------------------------------------

    // STEP 2: Draw to framebuffer
    //------------------------------------------------------------------------------------------
    // NOTE: Shader is used to convert HDR equirectangular environment map to cubemap equivalent (6 faces)
    rlEnableShader(shader.id);

    // Define projection matrix and send it to shader
    Matrix matFboProjection = MatrixPerspective(90.0*DEG2RAD, 1.0, RL_CULL_DISTANCE_NEAR, RL_CULL_DISTANCE_FAR);
    rlSetUniformMatrix(shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_PROJECTION], matFboProjection);

    // Define view matrix for every side of the cubemap
    Matrix[6] fboViews = [
        MatrixLookAt(Vector3( 0.0f, 0.0f, 0.0f ), Vector3(  1.0f,  0.0f,  0.0f ), Vector3( 0.0f, -1.0f,  0.0f )),
        MatrixLookAt(Vector3( 0.0f, 0.0f, 0.0f ), Vector3( -1.0f,  0.0f,  0.0f ), Vector3( 0.0f, -1.0f,  0.0f )),
        MatrixLookAt(Vector3( 0.0f, 0.0f, 0.0f ), Vector3(  0.0f,  1.0f,  0.0f ), Vector3( 0.0f,  0.0f,  1.0f )),
        MatrixLookAt(Vector3( 0.0f, 0.0f, 0.0f ), Vector3(  0.0f, -1.0f,  0.0f ), Vector3( 0.0f,  0.0f, -1.0f )),
        MatrixLookAt(Vector3( 0.0f, 0.0f, 0.0f ), Vector3(  0.0f,  0.0f,  1.0f ), Vector3( 0.0f, -1.0f,  0.0f )),
        MatrixLookAt(Vector3( 0.0f, 0.0f, 0.0f ), Vector3(  0.0f,  0.0f, -1.0f ), Vector3( 0.0f, -1.0f,  0.0f ))
    ];

    rlViewport(0, 0, size, size);   // Set viewport to current fbo dimensions

    // Activate and enable texture for drawing to cubemap faces
    rlActiveTextureSlot(0);
    rlEnableTexture(panorama.id);

    for (int i = 0; i < 6; i++)
    {
        // Set the view matrix for the current cube face
        rlSetUniformMatrix(shader.locs[ShaderLocationIndex.SHADER_LOC_MATRIX_VIEW], fboViews[i]);

        // Select the current cubemap face attachment for the fbo
        // WARNING: This function by default enables->attach->disables fbo!!!
        rlFramebufferAttach(
            fbo,
            cubemap.id,
            rlFramebufferAttachType.RL_ATTACHMENT_COLOR_CHANNEL0,
            rlFramebufferAttachTextureType.RL_ATTACHMENT_CUBEMAP_POSITIVE_X + i,
            0
        );
        rlEnableFramebuffer(fbo);

        // Load and draw a cube, it uses the current enabled texture
        rlClearScreenBuffers();
        rlLoadDrawCube();

        // ALTERNATIVE: Try to use internal batch system to draw the cube instead of rlLoadDrawCube
        // for some reason this method does not work, maybe due to cube triangles definition? normals pointing out?
        // TODO: Investigate this issue...
        //rlSetTexture(panorama.id); // WARNING: It must be called after enabling current framebuffer if using internal batch system!
        //rlClearScreenBuffers();
        //DrawCubeV(Vector3Zero(), Vector3One(), WHITE);
        //rlDrawRenderBatchActive();
    }
    //------------------------------------------------------------------------------------------

    // STEP 3: Unload framebuffer and reset state
    //------------------------------------------------------------------------------------------
    rlDisableShader();          // Unbind shader
    rlDisableTexture();         // Unbind texture
    rlDisableFramebuffer();     // Unbind framebuffer
    rlUnloadFramebuffer(fbo);   // Unload framebuffer (and automatically attached depth texture/renderbuffer)

    // Reset viewport dimensions to default
    rlViewport(0, 0, rlGetFramebufferWidth(), rlGetFramebufferHeight());
    rlEnableBackfaceCulling();
    //------------------------------------------------------------------------------------------

    cubemap.width = size;
    cubemap.height = size;
    cubemap.mipmaps = 1;
    cubemap.format = format;

    return cubemap;
}

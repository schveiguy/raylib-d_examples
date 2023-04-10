/**********************************************************************************************
*
*   raylib.lights - Some useful functions to deal with lights data
*
*   CONFIGURATION:
*
*   #define RLIGHTS_IMPLEMENTATION
*       Generates the implementation of the library into the included file.
*       If not defined, the library is in header only mode and can be included in other headers
*       or source files without problems. But only ONE file should hold the implementation.
*
*   LICENSE: zlib/libpng
*
*   Copyright (c) 2017-2023 Victor Fisac (@victorfisac) and Ramon Santamaria (@raysan5)
*
*   This software is provided "as-is", without any express or implied warranty. In no event
*   will the authors be held liable for any damages arising from the use of this software.
*
*   Permission is granted to anyone to use this software for any purpose, including commercial
*   applications, and to alter it and redistribute it freely, subject to the following restrictions:
*
*     1. The origin of this software must not be misrepresented; you must not claim that you
*     wrote the original software. If you use this software in a product, an acknowledgment
*     in the product documentation would be appreciated but is not required.
*
*     2. Altered source versions must be plainly marked as such, and must not be misrepresented
*     as being the original software.
*
*     3. This notice may not be removed or altered from any source distribution.
*
**********************************************************************************************
*
*   Translated to D (dlang.org) by Danilo Krahn ( https://github.com/D-a-n-i-l-o/ )
*
*   Date: 2023/04/10
*
**********************************************************************************************/
module raylib.rlights;

import raylib;

//----------------------------------------------------------------------------------
// Defines and Macros
//----------------------------------------------------------------------------------
const int MAX_LIGHTS = 4;         // Max dynamic lights supported by shader

//----------------------------------------------------------------------------------
// Types and Structures Definition
//----------------------------------------------------------------------------------

// Light data
struct Light {
    int type;
    bool enabled;
    Vector3 position;
    Vector3 target;
    Color color;
    float attenuation;

    // Shader locations
    int enabledLoc;
    int typeLoc;
    int positionLoc;
    int targetLoc;
    int colorLoc;
    int attenuationLoc;
};

// Light type
const int LIGHT_DIRECTIONAL = 0;
const int LIGHT_POINT       = 1;

enum LightType {
    Directional = 0,
    Point
}

//----------------------------------------------------------------------------------
// Global Variables Definition
//----------------------------------------------------------------------------------
static int lightsCount = 0;    // Current amount of created lights

//----------------------------------------------------------------------------------
// Module specific Functions Declaration
//----------------------------------------------------------------------------------
// ...

//----------------------------------------------------------------------------------
// Module Functions Definition
//----------------------------------------------------------------------------------

// Create a light and get shader locations
Light CreateLight(int type, Vector3 position, Vector3 target, Color color, Shader shader) //@nogc nothrow
{
    Light light = { 0 };

    if (lightsCount < MAX_LIGHTS)
    {
        light.enabled = true;
        light.type = type;
        light.position = position;
        light.target = target;
        light.color = color;

        // NOTE: Lighting shader naming must be the provided ones
        light.enabledLoc = GetShaderLocation(shader, TextFormat("lights[%i].enabled", lightsCount));
        light.typeLoc = GetShaderLocation(shader, TextFormat("lights[%i].type", lightsCount));
        light.positionLoc = GetShaderLocation(shader, TextFormat("lights[%i].position", lightsCount));
        light.targetLoc = GetShaderLocation(shader, TextFormat("lights[%i].target", lightsCount));
        light.colorLoc = GetShaderLocation(shader, TextFormat("lights[%i].color", lightsCount));

        UpdateLightValues(shader, light);

        lightsCount++;
    }

    return light;
}

// Send light properties to shader
// NOTE: Light shader locations should be available
void UpdateLightValues(Shader shader, Light light) //@nogc nothrow
{
    // Send to shader light enabled state and type
    SetShaderValue(shader, light.enabledLoc, &light.enabled, ShaderUniformDataType.SHADER_UNIFORM_INT);
    SetShaderValue(shader, light.typeLoc, &light.type, ShaderUniformDataType.SHADER_UNIFORM_INT);

    // Send to shader light position values
    float[3] position = [ light.position.x, light.position.y, light.position.z ];
    SetShaderValue(shader, light.positionLoc, &position[0], ShaderUniformDataType.SHADER_UNIFORM_VEC3);

    // Send to shader light target position values
    float[3] target = [ light.target.x, light.target.y, light.target.z ];
    SetShaderValue(shader, light.targetLoc, &target[0], ShaderUniformDataType.SHADER_UNIFORM_VEC3);

    // Send to shader light color values
    float[4] color = [ cast(float)light.color.r/cast(float)255, cast(float)light.color.g/cast(float)255,
                       cast(float)light.color.b/cast(float)255, cast(float)light.color.a/cast(float)255 ];
    SetShaderValue(shader, light.colorLoc, &color[0], ShaderUniformDataType.SHADER_UNIFORM_VEC4);
}

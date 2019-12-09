#version 150

uniform mat4 u_ViewProj;    // We're actually passing the inverse of the viewproj
                            // from our CPU, but it's named u_ViewProj so we don't
                            // have to bother rewriting our ShaderProgram class

uniform ivec2 u_Dimensions; // Screen dimensions

uniform vec3 u_Eye; // Camera pos

uniform float u_Time;

uniform vec3 u_SunDir;
uniform vec3 u_SunColor;
uniform vec3 u_SkyBaseColor;

out vec3 outColor;

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;


void main()
{
    vec2 ndc = (gl_FragCoord.xy / vec2(u_Dimensions)) * 2.0 - 1.0; // -1 to 1 NDC



    vec4 p = vec4(ndc.xy, 1, 1); // Pixel at the far clip plane
    p *= 1000.0; // Times far clip plane value
    p = /*Inverse of*/ u_ViewProj * p; // Convert from unhomogenized screen to world

    vec3 rayDir = normalize(p.xyz - u_Eye);




    // Add a glowing sun in the sky

    // use the sunDir computed in mygl
    vec3 sunDir = u_SunDir;

    float sunSize = 10;
    float angle = acos(dot(rayDir, sunDir)) * 360.0 / PI;

    // the color only shows around the sun at low altitude
    vec3 skyRiseHoriz = vec3(66.f, 22.f, 12.f) * (1.f/ 255.f);
    vec3 skySetHoriz = vec3(66.f, 22.f, 12.f) * (1.f/ 255.f);
    vec3 lessBlue = vec3(255.f, 255.f, 255.f) * (1.f/ 255.f);
    vec3 moreBlue = vec3(0.f, 181.f, 255.f) * (1.f/ 255.f);
    vec3 purpleNight = vec3(133.f, 89.f, 136.f) * (1.f/ 255.f);
    vec3 darkNight = vec3(20.f, 24.f, 82.f) * (1.f/ 255.f);
    vec3 tint;


        // If the angle between our ray dir and vector to center of sun
        // is less than the threshold, then we're looking at the sun
    if(angle < sunSize) {
        // Full center of sun
        if(angle < sunSize * 0.75) {
            // the direction of the sun determines the sum color
            outColor = u_SunColor;
        }
        // Corona of sun, mix with sky color
        else {

            outColor = mix(u_SunColor, u_SkyBaseColor, (angle - sunSize*0.75) / (sunSize*0.25));
        }
    }
    // Otherwise our ray is looking into just the sky
    else {

        if(sunDir[1] > 0)
        {
            // the sky should be bluer at a higher degree from horizon
            tint = mix(lessBlue, moreBlue, rayDir[1]);
            outColor = tint * u_SkyBaseColor;
        }
        else{
            tint = mix(lessBlue, purpleNight, rayDir[1]);
            outColor = tint * u_SkyBaseColor;

        }



    }

}

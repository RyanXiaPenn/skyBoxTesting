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

// Sunset palette
const vec3 sunset[5] = vec3[](vec3(255, 229, 119) / 255.0,
                               vec3(254, 192, 81) / 255.0,
                               vec3(255, 137, 103) / 255.0,
                               vec3(253, 96, 81) / 255.0,
                               vec3(57, 32, 51) / 255.0);
// Dusk palette
const vec3 dusk[5] = vec3[](vec3(144, 96, 144) / 255.0,
                            vec3(96, 72, 120) / 255.0,
                            vec3(72, 48, 120) / 255.0,
                            vec3(48, 24, 96) / 255.0,
                            vec3(0, 24, 72) / 255.0);
// SunRise palette
const vec3 sunRise[5] = vec3[](vec3(220, 229, 140) / 255.0,
                               vec3(255, 192, 100) / 255.0,
                               vec3(255, 137, 120) / 255.0,
                               vec3(255, 96, 100) / 255.0,
                               vec3(253, 94, 83) / 255.0);

vec3 sunRiseSun = vec3(253, 94, 83) / 255.0;
vec3 noonSun = vec3(255.f, 255.f, 255.f) / 255.0;

// Noon palette
//const vec3 noon[5] = vec3[](vec3(220, 229, 140) / 255.0,
//                               vec3(255, 192, 100) / 255.0,
//                               vec3(255, 137, 120) / 255.0,
//                               vec3(255, 96, 100) / 255.0,
//                               vec3(135, 206, 235) / 255.0);

const vec3 noon[5] = vec3[](vec3(255, 255, 255) / 255.0,
                               vec3(200, 200, 200) / 255.0,
                               vec3(150, 150, 150) / 255.0,
                               vec3(100, 100, 100) / 255.0,
                               vec3(50, 50, 50) / 255.0);




const vec3 sunColor = vec3(255, 255, 190) / 255.0;
const vec3 cloudColor = sunset[3];

vec2 sphereToUV(vec3 p) {
    float phi = atan(p.z, p.x);
    if(phi < 0) {
        phi += TWO_PI;
    }
    float theta = acos(p.y);
    return vec2(1 - phi / TWO_PI, 1 - theta / PI);
}

vec3 uvToSunset(vec2 uv) {
    if(uv.y < 0.5) {
        return sunset[0];
    }
    else if(uv.y < 0.55) {
        return mix(sunset[0], sunset[1], (uv.y - 0.5) / 0.05);
    }
    else if(uv.y < 0.6) {
        return mix(sunset[1], sunset[2], (uv.y - 0.55) / 0.05);
    }
    else if(uv.y < 0.65) {
        return mix(sunset[2], sunset[3], (uv.y - 0.6) / 0.05);
    }
    else if(uv.y < 0.75) {
        return mix(sunset[3], sunset[4], (uv.y - 0.65) / 0.1);
    }
    return sunset[4];
}

vec3 uvToDusk(vec2 uv) {
    if(uv.y < 0.5) {
        return dusk[0];
    }
    else if(uv.y < 0.55) {
        return mix(dusk[0], dusk[1], (uv.y - 0.5) / 0.05);
    }
    else if(uv.y < 0.6) {
        return mix(dusk[1], dusk[2], (uv.y - 0.55) / 0.05);
    }
    else if(uv.y < 0.65) {
        return mix(dusk[2], dusk[3], (uv.y - 0.6) / 0.05);
    }
    else if(uv.y < 0.75) {
        return mix(dusk[3], dusk[4], (uv.y - 0.65) / 0.1);
    }
    return dusk[4];
}

vec3 uvToNoon(vec2 uv){
    if(uv.y < 0.5) {
        return noon[0];
    }
    else if(uv.y < 0.55) {
        return mix(noon[0], noon[1], (uv.y - 0.5) / 0.05);
    }
    else if(uv.y < 0.6) {
        return mix(noon[1], noon[2], (uv.y - 0.55) / 0.05);
    }
    else if(uv.y < 0.65) {
        return mix(noon[2], noon[3], (uv.y - 0.6) / 0.05);
    }
    else if(uv.y < 0.75) {
        return mix(noon[3], noon[4], (uv.y - 0.65) / 0.1);
    }
    return noon[4];
}

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec3 random3( vec3 p ) {
    return fract(sin(vec3(dot(p,vec3(127.1, 311.7, 191.999)),
                          dot(p,vec3(269.5, 183.3, 765.54)),
                          dot(p, vec3(420.69, 631.2,109.21))))
                 *43758.5453);
}

float WorleyNoise3D(vec3 p)
{
    // Tile the space
    vec3 pointInt = floor(p);
    vec3 pointFract = fract(p);

    float minDist = 1.0; // Minimum distance initialized to max.

    // Search all neighboring cells and this cell for their point
    for(int z = -1; z <= 1; z++)
    {
        for(int y = -1; y <= 1; y++)
        {
            for(int x = -1; x <= 1; x++)
            {
                vec3 neighbor = vec3(float(x), float(y), float(z));

                // Random point inside current neighboring cell
                vec3 point = random3(pointInt + neighbor);

                // Animate the point
                point = 0.5 + 0.5 * sin(u_Time * 0.01 + 6.2831 * point); // 0 to 1 range

                // Compute the distance b/t the point and the fragment
                // Store the min dist thus far
                vec3 diff = neighbor + point - pointFract;
                float dist = length(diff);
                minDist = min(minDist, dist);
            }
        }
    }
    return minDist;
}

float WorleyNoise(vec2 uv)
{
    // Tile the space
    vec2 uvInt = floor(uv);
    vec2 uvFract = fract(uv);

    float minDist = 1.0; // Minimum distance initialized to max.

    // Search all neighboring cells and this cell for their point
    for(int y = -1; y <= 1; y++)
    {
        for(int x = -1; x <= 1; x++)
        {
            vec2 neighbor = vec2(float(x), float(y));

            // Random point inside current neighboring cell
            vec2 point = random2(uvInt + neighbor);

            // Animate the point
            point = 0.5 + 0.5 * sin(u_Time * 0.01 + 6.2831 * point); // 0 to 1 range

            // Compute the distance b/t the point and the fragment
            // Store the min dist thus far
            vec2 diff = neighbor + point - uvFract;
            float dist = length(diff);
            minDist = min(minDist, dist);
        }
    }
    return minDist;
}

float worleyFBM(vec3 uv) {
    float sum = 0;
    float freq = 4;
    float amp = 0.5;
    for(int i = 0; i < 8; i++) {
        sum += WorleyNoise3D(uv * freq) * amp;
        freq *= 2;
        amp *= 0.5;
    }
    return sum;
}

//#define RAY_AS_COLOR
//#define SPHERE_UV_AS_COLOR
#define WORLEY_OFFSET

void main()
{
    vec2 ndc = (gl_FragCoord.xy / vec2(u_Dimensions)) * 2.0 - 1.0; // -1 to 1 NDC

//    outColor = vec3(ndc * 0.5 + 0.5, 1);

    vec4 p = vec4(ndc.xy, 1, 1); // Pixel at the far clip plane
    p *= 1000.0; // Times far clip plane value
    p = /*Inverse of*/ u_ViewProj * p; // Convert from unhomogenized screen to world

    vec3 rayDir = normalize(p.xyz - u_Eye);

#ifdef RAY_AS_COLOR
    outColor = 0.5 * (rayDir + vec3(1,1,1));
    return;
#endif

    vec2 uv = sphereToUV(rayDir);
#ifdef SPHERE_UV_AS_COLOR
    outColor = vec3(uv, 0);
    return;
#endif


    vec2 offset = vec2(0.0);
#ifdef WORLEY_OFFSET
    // Get a noise value in the range [-1, 1]
    // by using Worley noise as the noise basis of FBM
    offset = vec2(worleyFBM(rayDir));
    offset *= 2.0;
    offset -= vec2(1.0);
#endif

    // Compute a gradient from the bottom of the sky-sphere to the top
    vec3 sunsetColor = uvToSunset(uv + offset * 0.1);
    vec3 duskColor = uvToDusk(uv + offset * 0.1);
    vec3 noonColor = uvToNoon(uv + offset * 0.1);

    outColor = sunsetColor;


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


//        if(angle <= 6*sunSize)
//        {
//            // from 20 to 40 degrees, the horizon
//            outColor = mix(skyRiseHoriz, u_SkyBaseColor, (angle-sunSize)/((6-1)*sunSize));
//            outColor = u_SkyBaseColor;
//        }
//        else{
//            outColor = u_SkyBaseColor;
//        }
    }


//    else if (false){
//        // ********* afternoon section
//        // If the angle between our ray dir and vector to center of sun
//        // is less than the threshold, then we're looking at the sun
//        if(angle < sunSize) {
//            // Full center of sun
//            if(angle < 5) {
//                outColor = u_SunColor;
//            }
//            // Corona of sun, mix with sky color
//            else {
//                outColor = mix(u_SunColor, sunsetColor, (angle - 5) / 15);
//            }
//        }
//        // Otherwise our ray is looking into just the sky
//        else {
//            float raySunDot = dot(rayDir, sunDir);
//    #define SUNSET_THRESHOLD 0.75
//    #define DUSK_THRESHOLD -0.1
//            if(raySunDot > SUNSET_THRESHOLD) {
//                // Do nothing, sky is already correct color
//            }
//            // Any dot product between 0.75 and -0.1 is a LERP b/t sunset and dusk color
//            else if(raySunDot > DUSK_THRESHOLD) {
//                float t = (raySunDot - SUNSET_THRESHOLD) / (DUSK_THRESHOLD - SUNSET_THRESHOLD);
//                outColor = mix(outColor, duskColor, t);
//            }
//            // Any dot product <= -0.1 are pure dusk color
//            else {
//                outColor = duskColor;
//                //outColor = vec3(0, 0, 0);
//            }
//        }

//    }

}

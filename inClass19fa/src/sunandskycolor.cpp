#include "sunandskycolor.h"

sunAndSkyColor::sunAndSkyColor(float cycleSpeed):
      // cycle speed, larger means faster day and night cycle
      cycleSpeed(cycleSpeed),
      // sun direction color, and sky color
      sunDir(glm::vec3(0, 0, 0)), sunColor(glm::vec3(1, 1, 1)),
      skyBaseColor(glm::vec3(1, 1, 1)),
      // Unique sun color at sun rise, noon, and sun set
      sunRiseColor(glm::vec3(247.f, 222.f, 85.f) * (1.f / 255.f)),
      sunNoonColor(glm::vec3(255.f, 255.f, 255.f) * (1.f / 255.f)),
      sunSetColor(glm::vec3(247.f, 222.f, 85.f) * (1.f / 255.f)),
      moonMidNightColor(glm::vec3(100.f, 100.f, 100.f) * (1.f / 255.f)),
      // Unique sky color at sun rise, noon, and sun set
      skyRiseColor(glm::vec3(66.f, 22.f, 12.f) * (1.f/ 255.f)),
      skyNoonColor(glm::vec3(135.f, 206.f, 255.f) * (1.f / 255.f)),
      skySetColor(glm::vec3(66.f, 22.f, 12.f) * (1.f / 255.f)),
      skyMidNightColor(glm::vec3(20, 20, 50) * (1.f / 255.f))

{}

void sunAndSkyColor::computeSunDirAndColor(float time)
{
    sunDir = glm::normalize(glm::vec3(glm::rotate(glm::mat4(1.f), - cycleSpeed* time, glm::vec3(1.f, 0.f, 0.f))
                                      * glm::vec4(0.f, 0.f, 1.f, 1)));

    if(sunDir[1] >= 0 && sunDir[2] >= 0)
    {
        sunColor = glm::mix(sunRiseColor, sunNoonColor, sunDir[1]);
        skyBaseColor = glm::mix(skyRiseColor, skyNoonColor, sunDir[1]);
    }
    else if(sunDir[1] >= 0 && sunDir[2] < 0)
    {
        sunColor = glm::mix(sunSetColor, sunNoonColor, sunDir[1]);
        skyBaseColor = glm::mix(skySetColor, skyNoonColor, sunDir[1]);
    }
    else if(sunDir[1] < 0 && sunDir[2] < 0)
    {
        sunColor = glm::mix(sunSetColor, moonMidNightColor, -sunDir[1]);
        skyBaseColor = glm::mix(skySetColor, skyMidNightColor, -sunDir[1]);
    }
    else if(sunDir[1] < 0 && sunDir[2] > 0)
    {
        sunColor = glm::mix(sunSetColor, moonMidNightColor, -sunDir[1]);
        skyBaseColor = glm::mix(skyRiseColor, skyMidNightColor, -sunDir[1]);
    }
}

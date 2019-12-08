#ifndef SUNANDSKYCOLOR_H
#define SUNANDSKYCOLOR_H

#include <openglcontext.h>
#include <utils.h>
#include <shaderprogram.h>
#include <scene/cube.h>
#include <scene/worldaxes.h>
#include "camera.h"
#include <scene/terrain.h>
#include <scene/quad.h>

#include <QOpenGLVertexArrayObject>
#include <QOpenGLShaderProgram>
#include <la.h>

#include <iostream>
#include <QApplication>
#include <QKeyEvent>


class sunAndSkyColor
{
public:
    float cycleSpeed;

    // Sun direction and corresponding sun color and sky base color
    glm::vec3 sunDir;
    glm::vec3 sunColor;
    glm::vec3 skyBaseColor;

    // Unique sun color at sun rise, noon, and sun set
    glm::vec3 sunRiseColor;
    glm::vec3 sunNoonColor;
    glm::vec3 sunSetColor;
    glm::vec3 moonMidNightColor;

    // Unique sky color at sun rise, noon, and sun set
    glm::vec3 skyRiseColor;
    glm::vec3 skyNoonColor;
    glm::vec3 skySetColor;
    glm::vec3 skyMidNightColor;



public:
    sunAndSkyColor(float cycleSpeed);
    void computeSunDirAndColor(float time);
};

#endif // SUNANDSKYCOLOR_H

//
//  Triangle.m
//  flutter_opengl_es
//
//  Created by daniate on 2022/9/18.
//

#import "Triangle.h"
#import "Shader.h"
#import <OpenGLES/ES2/glext.h>

static float POSITIONS[] = {
            0, 1, 0,
            -0.866f, -0.5f, 0,
            0.866f, -0.5f, 0
};
static float COLORS[] = {
        1, 0, 0, 1.0f,
        0, 1, 0, 1.0f,
        0, 0, 1, 1.0f,
};

static char * VSH_SOURCE = ""
        "uniform mat4 uMVPMatrix;"
        "attribute vec4 vPosition;"
        "attribute vec4 vColor;"
        "varying vec4 oColor;"
        "void main() {"
        "    gl_Position = uMVPMatrix * vPosition;"
        "    oColor = vColor;"
        "}";

static char * FSH_SOURCE = ""
        "precision mediump float;"
        "varying vec4 oColor;"
        "void main() {"
        "    gl_FragColor = oColor;"
        "}";

@implementation Triangle {
    GLuint _vao;// vertex array object
    GLuint _positionBuffer;
    GLuint _colorBuffer;
    Shader *_shader;
}

- (instancetype)init {
    if (self = [super init]) {
        
        _shader = [[Shader alloc] initWithVertexShader:[NSString stringWithUTF8String:VSH_SOURCE] fragmentShader:[NSString stringWithUTF8String:FSH_SOURCE]];
        
        glGenVertexArraysOES(1, &_vao);
        glBindVertexArrayOES(_vao);
        
        glGenBuffers(1, &_positionBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _positionBuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     sizeof(POSITIONS),
                     POSITIONS,
                     GL_STATIC_DRAW);
        
        int positionLocation = glGetAttribLocation(_shader.programHandle, "vPosition");
        glEnableVertexAttribArray(positionLocation);
        glVertexAttribPointer(positionLocation,
                              3,
                              GL_FLOAT, GL_FALSE,
                              sizeof(POSITIONS) / 3,
                              (const GLvoid *)NULL);
        
        glGenBuffers(1, &_colorBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _colorBuffer);
        glBufferData(GL_ARRAY_BUFFER,
                     sizeof(COLORS),
                     COLORS,
                     GL_STATIC_DRAW);
        
        int colorLocation = glGetAttribLocation(_shader.programHandle, "vColor");
        glEnableVertexAttribArray(colorLocation);
        glVertexAttribPointer(colorLocation,
                              4,
                              GL_FLOAT,
                              GL_FALSE,
                              sizeof(COLORS) / 3,
                              (const GLvoid *)NULL);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArrayOES(0);
    }
    return self;
}

float radians;

- (void)render {
    glUseProgram(_shader.programHandle);
    glBindVertexArrayOES(_vao);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(-1, 1, -1, 1, 1, 3);
    
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0, 0, 1.5f, 0.0f, 0.0f, 0.0f, 0, 1.0f, 0.0f);
    
    GLKMatrix4 vpMatrix = GLKMatrix4Multiply(projectionMatrix, viewMatrix);
    
    // 更新模型矩阵，这里创建一个旋转变换
    radians += M_PI / 180;
    if (radians > 2 * M_PI) {
        radians = 0.0f;
    }
    
    GLKMatrix4 modelMatrix = GLKMatrix4MakeRotation(radians, 0, 0, 1);
    
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(vpMatrix, modelMatrix);
    
    int mvpMatrixLocation = glGetUniformLocation(_shader.programHandle, "uMVPMatrix");
    glUniformMatrix4fv(mvpMatrixLocation, 1, false, mvpMatrix.m);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glBindVertexArrayOES(0);
}
@end

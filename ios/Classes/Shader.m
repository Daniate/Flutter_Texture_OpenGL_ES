//
//  Shader.m
//  OpenGL ES Shader Effects
//
//  Created by Daniate on 2019/12/10.
//  Copyright © 2019 Daniate. All rights reserved.
//

#import "Shader.h"

@implementation Shader {
    GLuint _programHandle;
}
- (instancetype)initWithVertexShader:(NSString *)vsh fragmentShader:(NSString *)fsh {
    if (self = [super init]) {
        // 创建着色器程序
        _programHandle = glCreateProgram();
        
        GLuint vertexShader = [self compileShaderContent:vsh type:GL_VERTEX_SHADER];
        GLuint fragmentShader = [self compileShaderContent:fsh type:GL_FRAGMENT_SHADER];
        
        glAttachShader(_programHandle, vertexShader);
        glAttachShader(_programHandle, fragmentShader);
        
        glLinkProgram(self.programHandle);
        
        GLint logLen = 0;
        glGetProgramiv(self.programHandle, GL_INFO_LOG_LENGTH, &logLen);
        if (logLen > 0) {
            GLchar *infolog = (GLchar *)malloc(logLen);
            glGetProgramInfoLog(self.programHandle, logLen, &logLen, infolog);
            NSLog(@"glGetProgramInfoLog: %s", infolog);
            free(infolog);
            infolog = NULL;
        }
        
        glUseProgram(self.programHandle);
    }
    return self;
}

- (GLuint)compileShaderContent:(NSString *)shaderContent type:(GLenum)type {
    GLuint shader = glCreateShader(type);
    const char *shaderString = shaderContent.UTF8String;
    // 最后一个参数不要传入非NULL的长度指针，以在glsl中使用中文注释；否则程序无法运行。@see: https://blog.csdn.net/jeffasd/article/details/52139262
    glShaderSource(shader, 1, (const GLchar *const *)&shaderString, NULL);
    
    glCompileShader(shader);
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if (GL_FALSE == status) {
        GLint logLen;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLen);
        
        GLsizei bufsize = logLen * sizeof(GLchar) + 1;
        GLchar *infolog = malloc(bufsize);
        
        if (infolog) {
            memset(infolog, '\0', bufsize);
            
            GLsizei length;
            glGetShaderInfoLog(shader, bufsize, &length, infolog);
            
            NSLog(@"error log: %s", infolog);
            
            free(infolog);
            infolog = NULL;
        }
        
        exit(EXIT_FAILURE);
    }
    
    return shader;
}

@end

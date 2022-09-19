//
//  OpenGLESTexture.m
//  flutter_opengl_es
//
//  Created by daniate on 2022/9/18.
//

#import "OpenGLESTexture.h"
#import "Triangle.h"

@interface OpenGLESTexture ()
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;
@property (nonatomic, assign) CVOpenGLESTextureRef glTexture;
@property (nonatomic, assign) GLuint frameBuffer;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;

@property (nonatomic, strong) Triangle *triangle;
@end

@implementation OpenGLESTexture
- (instancetype)initWithSize:(CGSize)size callback:(OpenGLESTextureRenderCallBack)callback {
    self = [super init];
    if (self) {
        _size = size;
        _callback = callback;
        
        [self initGL];
        
        self.triangle = [[Triangle alloc] init];
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        displayLink.preferredFramesPerSecond = FPS;
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)render:(CADisplayLink *)displayLink {
    [EAGLContext setCurrentContext:_context];
    glViewport(0, 0, _size.width, _size.height);
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.triangle render];
    
    glFlush();
    self.callback();
}

- (void)initGL {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    [EAGLContext setCurrentContext:_context];
    [self createCVBufferWithSize:self.size];
    
    glBindTexture(CVOpenGLESTextureGetTarget(self.glTexture), CVOpenGLESTextureGetName(self.glTexture));
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER,
                           GL_COLOR_ATTACHMENT0,
                           GL_TEXTURE_2D,
                           CVOpenGLESTextureGetName(self.glTexture),
                           0);
    assert(GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus(GL_FRAMEBUFFER));
}

- (void)createCVBufferWithSize:(CGSize)size {
    
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                                NULL,
                                                _context,
                                                NULL,
                                                &_textureCache);
    assert(kCVReturnSuccess == err);
    
    CFDictionaryRef empty;
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault,
                               NULL,
                               NULL,
                               0,
                               &kCFTypeDictionaryKeyCallBacks,
                               &kCFTypeDictionaryValueCallBacks);
    assert(empty);
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                      1,
                                      &kCFTypeDictionaryKeyCallBacks,
                                      &kCFTypeDictionaryValueCallBacks);
    assert(attrs);
    CFDictionarySetValue(attrs,
                         kCVPixelBufferIOSurfacePropertiesKey,
                         empty);
    CVPixelBufferCreate(kCFAllocatorDefault,
                        size.width,
                        size.height,
                        kCVPixelFormatType_32BGRA,
                        attrs,
                        &_pixelBuffer);
    
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                 self.textureCache,
                                                 self.pixelBuffer,
                                                 NULL,
                                                 GL_TEXTURE_2D,
                                                 GL_RGBA,
                                                 size.width,
                                                 size.height,
                                                 GL_BGRA,
                                                 GL_UNSIGNED_BYTE,
                                                 0,
                                                 &_glTexture);
    
    CFRelease(empty);
    CFRelease(attrs);
}

#pragma mark - FlutterTexture
/** Copy the contents of the texture into a `CVPixelBuffer`. */
- (CVPixelBufferRef _Nullable)copyPixelBuffer {
    CVBufferRetain(self.pixelBuffer);
    return self.pixelBuffer;
}

- (void)onTextureUnregistered:(NSObject<FlutterTexture>*)texture {
    NSLog(@"onTextureUnregistered: %@", texture);
}

@end

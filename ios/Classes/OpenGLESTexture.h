//
//  OpenGLESTexture.h
//  flutter_opengl_es
//
//  Created by daniate on 2022/9/18.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^OpenGLESTextureRenderCallBack)(void);

@interface OpenGLESTexture : NSObject <FlutterTexture>
@property (nonatomic, assign, readonly) CGSize size;
@property (nonatomic, copy, readonly) OpenGLESTextureRenderCallBack callback;
- (instancetype)initWithSize:(CGSize)size callback:(OpenGLESTextureRenderCallBack)callback;
@end

NS_ASSUME_NONNULL_END

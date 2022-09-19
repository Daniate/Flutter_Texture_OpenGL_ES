//
//  Shader.h
//  OpenGL ES Shader Effects
//
//  Created by Daniate on 2019/12/10.
//  Copyright © 2019 Daniate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Shader : NSObject
@property (nonatomic, assign, readonly) GLuint programHandle;
- (instancetype)initWithVertexShader:(NSString *)vsh
                      fragmentShader:(NSString *)fsh;
@end

NS_ASSUME_NONNULL_END

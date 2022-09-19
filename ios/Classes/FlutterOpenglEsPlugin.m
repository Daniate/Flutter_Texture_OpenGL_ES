#import "FlutterOpenglEsPlugin.h"
#import "OpenGLESTexture.h"

@interface FlutterOpenglEsPlugin ()
@property (nonatomic, strong) NSObject<FlutterPluginRegistrar> *registrar;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSObject<FlutterTexture> *> *textureMap;
@end

@implementation FlutterOpenglEsPlugin

- (instancetype)init {
    if (self = [super init]) {
        _textureMap = @{}.mutableCopy;
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_opengl_es"
            binaryMessenger:[registrar messenger]];
  FlutterOpenglEsPlugin* instance = [[FlutterOpenglEsPlugin alloc] init];
    instance.registrar = registrar;
    
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getOpenGLESTextureID" isEqualToString:call.method]) {
        int64_t textureID = 0;
        
        __weak FlutterOpenglEsPlugin *weakSelf = self;
        OpenGLESTexture *texture = [[OpenGLESTexture alloc] initWithSize:CGSizeMake(1024, 1024) callback:^{
            __strong FlutterOpenglEsPlugin *self = weakSelf;
            [self.registrar.textures textureFrameAvailable:textureID];
        }];
        
        textureID = [self.registrar.textures registerTexture:texture];
        
        self.textureMap[@(textureID)] = texture;
        
        result(@(textureID));
    }
  else if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end

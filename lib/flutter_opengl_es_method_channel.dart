import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_opengl_es_platform_interface.dart';

/// An implementation of [FlutterOpenglEsPlatform] that uses method channels.
class MethodChannelFlutterOpenglEs extends FlutterOpenglEsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_opengl_es');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<int?> getOpenGLESTextureID() async {
    final textureId = await methodChannel.invokeMethod<int>('getOpenGLESTextureID');
    return textureId;
  }
}

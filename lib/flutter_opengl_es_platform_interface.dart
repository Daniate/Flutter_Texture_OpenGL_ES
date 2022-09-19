import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_opengl_es_method_channel.dart';

abstract class FlutterOpenglEsPlatform extends PlatformInterface {
  /// Constructs a FlutterOpenglEsPlatform.
  FlutterOpenglEsPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOpenglEsPlatform _instance = MethodChannelFlutterOpenglEs();

  /// The default instance of [FlutterOpenglEsPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOpenglEs].
  static FlutterOpenglEsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOpenglEsPlatform] when
  /// they register themselves.
  static set instance(FlutterOpenglEsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<int?> getOpenGLESTextureID() {
    throw UnimplementedError('getOpenGLESTextureID() has not been implemented.');
  }
}

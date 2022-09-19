
import 'flutter_opengl_es_platform_interface.dart';

class FlutterOpenglEs {
  Future<String?> getPlatformVersion() {
    return FlutterOpenglEsPlatform.instance.getPlatformVersion();
  }

  Future<int?> getOpenGLESTextureID() {
    return FlutterOpenglEsPlatform.instance.getOpenGLESTextureID();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_opengl_es/flutter_opengl_es.dart';
import 'package:flutter_opengl_es/flutter_opengl_es_platform_interface.dart';
import 'package:flutter_opengl_es/flutter_opengl_es_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterOpenglEsPlatform
    with MockPlatformInterfaceMixin
    implements FlutterOpenglEsPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterOpenglEsPlatform initialPlatform = FlutterOpenglEsPlatform.instance;

  test('$MethodChannelFlutterOpenglEs is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterOpenglEs>());
  });

  test('getPlatformVersion', () async {
    FlutterOpenglEs flutterOpenglEsPlugin = FlutterOpenglEs();
    MockFlutterOpenglEsPlatform fakePlatform = MockFlutterOpenglEsPlatform();
    FlutterOpenglEsPlatform.instance = fakePlatform;

    expect(await flutterOpenglEsPlugin.getPlatformVersion(), '42');
  });
}

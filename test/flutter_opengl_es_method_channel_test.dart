import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_opengl_es/flutter_opengl_es_method_channel.dart';

void main() {
  MethodChannelFlutterOpenglEs platform = MethodChannelFlutterOpenglEs();
  const MethodChannel channel = MethodChannel('flutter_opengl_es');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

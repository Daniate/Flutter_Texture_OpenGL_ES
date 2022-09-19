package com.daniate.flutter_opengl_es;

import android.graphics.SurfaceTexture;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.view.TextureRegistry;

/** FlutterOpenglEsPlugin */
public class FlutterOpenglEsPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  private FlutterPluginBinding pluginBinding;

  private OpenGLESTexture glesTexture;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    pluginBinding = flutterPluginBinding;

    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_opengl_es");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getOpenGLESTextureID")) {
      TextureRegistry.SurfaceTextureEntry entry = pluginBinding.getTextureRegistry().createSurfaceTexture();
      SurfaceTexture surfaceTexture = entry.surfaceTexture();

      surfaceTexture.setDefaultBufferSize(1024, 1024);

      glesTexture = new OpenGLESTexture(surfaceTexture);
      glesTexture.startRendering();

      result.success(entry.id());
    }
    else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}

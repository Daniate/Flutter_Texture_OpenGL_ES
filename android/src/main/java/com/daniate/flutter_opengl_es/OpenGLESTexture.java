package com.daniate.flutter_opengl_es;

import static android.opengl.EGL15.EGL_CONTEXT_MAJOR_VERSION;

import android.graphics.SurfaceTexture;

import android.opengl.EGL14;
import android.opengl.EGLConfig;
import android.opengl.GLES30;
import android.opengl.GLES31;
import android.opengl.GLUtils;
import android.opengl.Matrix;
import android.os.Build;
import android.util.Log;

import androidx.annotation.RequiresApi;

import android.opengl.EGLContext;
import android.opengl.EGLDisplay;
import android.opengl.EGLSurface;

public class OpenGLESTexture implements Runnable {
    private SurfaceTexture surfaceTexture;
    private boolean isRendering;

    private EGLContext eglContext;
    private EGLDisplay eglDisplay;
    private EGLSurface eglSurface;

    public OpenGLESTexture(SurfaceTexture surfaceTexture) {
        this.surfaceTexture = surfaceTexture;
    }

    public void startRendering() {
        isRendering = true;
        Thread thread = new Thread(this);
        thread.start();
    }

    public void stopRendering() {
        isRendering = false;
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    private void initGL() {
        eglDisplay = EGL14.eglGetDisplay(EGL14.EGL_DEFAULT_DISPLAY);
        if (null == eglDisplay || EGL14.EGL_NO_DISPLAY == eglDisplay) {
            throw new RuntimeException("eglGetDisplay: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
        }

        int[] params = new int[2];
        if (!EGL14.eglInitialize(eglDisplay, params, 0, params, 1)) {
            throw new RuntimeException("eglInitialize: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
        }

        EGLConfig eglConfig = chooseEglConfig();
        eglContext = createContext(eglDisplay, eglConfig);
        if (null == eglContext || EGL14.EGL_NO_CONTEXT == eglContext) {
            throw new RuntimeException("eglCreateContext: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
        }

        int[] attrs = new int[]{
                EGL14.EGL_NONE,
        };
        eglSurface = EGL14.eglCreateWindowSurface(eglDisplay, eglConfig, surfaceTexture, attrs, 0);
        if (null == eglSurface || EGL14.EGL_NO_SURFACE == eglSurface) {
            throw new RuntimeException("eglCreateWindowSurface: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
        }

        if (!EGL14.eglMakeCurrent(eglDisplay, eglSurface, eglSurface, eglContext)) {
            throw new RuntimeException("eglMakeCurrent: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    private void deinitGL() {
        EGL14.eglMakeCurrent(eglDisplay, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_SURFACE, EGL14.EGL_NO_CONTEXT);
        EGL14.eglDestroySurface(eglDisplay, eglSurface);
        EGL14.eglDestroyContext(eglDisplay, eglContext);
        EGL14.eglTerminate(eglDisplay);
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    private EGLContext createContext(EGLDisplay eglDisplay, EGLConfig eglConfig) {
        int[] attrs = {
                EGL_CONTEXT_MAJOR_VERSION, 3,
                EGL14.EGL_NONE
        };
        return EGL14.eglCreateContext(eglDisplay, eglConfig, EGL14.EGL_NO_CONTEXT, attrs, 0);
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR1)
    private EGLConfig chooseEglConfig() {
        int[] configsCount = new int[1];
        EGLConfig[] configs = new EGLConfig[1];
        int[] configSpec = new int[]{
                EGL14.EGL_RENDERABLE_TYPE, 4,
                EGL14.EGL_RED_SIZE, 8,
                EGL14.EGL_GREEN_SIZE, 8,
                EGL14.EGL_BLUE_SIZE, 8,
                EGL14.EGL_ALPHA_SIZE, 8,
                EGL14.EGL_DEPTH_SIZE, 16,
                EGL14.EGL_STENCIL_SIZE, 0,
                EGL14.EGL_SAMPLE_BUFFERS, 1,
                EGL14.EGL_SAMPLES, 4,
                EGL14.EGL_NONE
        };

        if (!EGL14.eglChooseConfig(eglDisplay, configSpec, 0, configs, 0, 1, configsCount, 0)) {
            throw new IllegalArgumentException("Failed to choose config: " + GLUtils.getEGLErrorString(EGL14.eglGetError()));
        }

        if (configsCount[0] > 0) {
            return configs[0];
        }
        return null;
    }

    @Override
    protected void finalize() throws Throwable {
        super.finalize();
        stopRendering();
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR2)
    @Override
    public void run() {
        // EGLContext 需要在同一个线程中创建和使用
        initGL();

        final int fps = 60;
        final double frameTS = 1000 * 1.0 / fps;

        Triangle triangle = new Triangle();

        final float[] projectionMatrix = new float[16];
        final float[] viewMatrix = new float[16];
        final float[] modelMatrix = new float[16];

        final float[] vpMatrix = new float[16];
        final float[] mvpMatrix = new float[16];

        Matrix.frustumM(projectionMatrix, 0, -1, 1, -1, 1, 1, 3);
        // Set the camera position (View matrix)
        Matrix.setLookAtM(viewMatrix, 0, 0, 0, 1.5f, 0f, 0f, 0f, 0, 1.0f, 0.0f);

        float angle = 0.0f;

        while (this.isRendering) {
            long beginTS = System.currentTimeMillis();

            GLES31.glClearColor(0.2f, 0.3f, 0.3f, 1);
            GLES31.glClear(GLES31.GL_COLOR_BUFFER_BIT | GLES31.GL_DEPTH_BUFFER_BIT);
            {
                // 计算投影与视图变换
                Matrix.multiplyMM(vpMatrix, 0, projectionMatrix, 0, viewMatrix, 0);

                // 更新模型矩阵，这里创建一个旋转变换
                angle += 1.0;
                if (angle > 360.0f) {
                    angle = 0.0f;
                }
                Matrix.setRotateM(modelMatrix, 0, angle, 0, 0, -1.0f);

                Matrix.multiplyMM(mvpMatrix, 0, vpMatrix, 0, modelMatrix, 0);

                // 绘制三角形
                triangle.draw(mvpMatrix);
            }

            EGL14.eglSwapBuffers(eglDisplay, eglSurface);

            long endTS = System.currentTimeMillis();
            long delta = endTS - beginTS;
            if (delta < frameTS) {
                try {
                    Thread.sleep((long) (frameTS - delta));
                } catch (InterruptedException e) {
                }
            }
        }

        deinitGL();
    }
}

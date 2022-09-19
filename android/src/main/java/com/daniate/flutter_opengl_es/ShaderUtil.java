package com.daniate.flutter_opengl_es;

import android.opengl.GLES30;

public class ShaderUtil {
    /**
     *
     * @param type GLES30.GL_VERTEX_SHADER / GLES30.GL_FRAGMENT_SHADER
     * @param source shader source code
     * @return shader id
     */
    private static int loadShader(int type, String source) {
        int shader = GLES30.glCreateShader(type);

        GLES30.glShaderSource(shader, source);
        GLES30.glCompileShader(shader);

        return shader;
    }

    public static int loadVertexShader(String source) {
        return loadShader(GLES30.GL_VERTEX_SHADER, source);
    }

    public static int loadFragmentShader(String source) {
        return loadShader(GLES30.GL_FRAGMENT_SHADER, source);
    }
}

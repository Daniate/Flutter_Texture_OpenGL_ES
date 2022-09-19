package com.daniate.flutter_opengl_es;

import android.opengl.GLES30;
import android.os.Build;

import androidx.annotation.RequiresApi;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

public class Triangle {
    private FloatBuffer positionBuffer;
    private FloatBuffer colorBuffer;

    private IntBuffer vaoList;
    private IntBuffer vboList;

    // Vertex positions
    static final int COORDS_PER_POSITION = 3;
    static final float POSITIONS[] = {
            0, 1, 0,
            -(float) Math.sqrt(0.75), -0.5f, 0,
            (float) Math.sqrt(0.75), -0.5f, 0
    };
    private final int POSITION_STRIDE = COORDS_PER_POSITION * 4;

    // Vertex colors
    static final int COMPONENTS_PER_COLOR = 4;
    static final float COLORS[] = {
            1, 0, 0, 1.0f,
            0, 1, 0, 1.0f,
            0, 0, 1, 1.0f,
    };
    private final int COLOR_STRIDE = COMPONENTS_PER_COLOR * 4;

    private final int VERTEX_COUNT = POSITIONS.length / COORDS_PER_POSITION;

    private final String VSH_SOURCE = "" +
            "uniform mat4 uMVPMatrix;" +
            "attribute vec4 vPosition;" +
            "attribute vec4 vColor;" +
            "varying vec4 oColor;" +
            "void main() {" +
            "    gl_Position = uMVPMatrix * vPosition;" +
            "    oColor = vColor;" +
            "}";

    private final String FSH_SOURCE = "" +
            "precision mediump float;" +
            "varying vec4 oColor;" +
            "void main() {" +
            "    gl_FragColor = oColor;" +
            "}";

    private int shaderProgram;

    private int mvpMatrixLocation;
    private int positionLocation;
    private int colorLocation;

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR2)
    public Triangle() {
        // Create position data buffer
        ByteBuffer positionByteBuffer = ByteBuffer.allocateDirect(4 * POSITIONS.length);
        positionByteBuffer.order(ByteOrder.nativeOrder());
        positionBuffer = positionByteBuffer.asFloatBuffer();
        positionBuffer.put(POSITIONS);
        positionBuffer.position(0);

        // Create color data buffer
        ByteBuffer colorByteBuffer = ByteBuffer.allocateDirect(4 * COLORS.length);
        colorByteBuffer.order(ByteOrder.nativeOrder());
        colorBuffer = colorByteBuffer.asFloatBuffer();
        colorBuffer.put(COLORS);
        colorBuffer.position(0);

        // Load shader objects
        int vsh = ShaderUtil.loadVertexShader(VSH_SOURCE);
        int fsh = ShaderUtil.loadFragmentShader(FSH_SOURCE);

        // Load program object
        shaderProgram = GLES30.glCreateProgram();
        GLES30.glAttachShader(shaderProgram, vsh);
        GLES30.glAttachShader(shaderProgram, fsh);
        GLES30.glLinkProgram(shaderProgram);

        // Create vertex array objects
        int numVao = 1;
        vaoList = IntBuffer.allocate(numVao);
        GLES30.glGenVertexArrays(numVao, vaoList);

        // Create vertex buffer objects
        int numVbo = 2;
        vboList = IntBuffer.allocate(numVbo);
        GLES30.glGenBuffers(numVbo, vboList);

        GLES30.glBindVertexArray(vaoList.get(0));
        {
            {
                // VBO for vertex position
                GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vboList.get(0));
                GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER, 4 * POSITIONS.length, positionBuffer, GLES30.GL_STATIC_DRAW);
                positionLocation = GLES30.glGetAttribLocation(shaderProgram, "vPosition");
                GLES30.glEnableVertexAttribArray(positionLocation);
                GLES30.glVertexAttribPointer(positionLocation, COORDS_PER_POSITION, GLES30.GL_FLOAT, false, POSITION_STRIDE, 0);
            }
            {
                // VBO for vertex color
                GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vboList.get(1));
                GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER, 4 * COLORS.length, colorBuffer, GLES30.GL_STATIC_DRAW);
                colorLocation = GLES30.glGetAttribLocation(shaderProgram, "vColor");
                GLES30.glEnableVertexAttribArray(colorLocation);
                GLES30.glVertexAttribPointer(colorLocation, COMPONENTS_PER_COLOR, GLES30.GL_FLOAT, false, COLOR_STRIDE, 0);
            }
        }
        GLES30.glBindVertexArray(0);
    }

    @RequiresApi(api = Build.VERSION_CODES.JELLY_BEAN_MR2)
    public void draw(float[] mvpMatrix) {
        GLES30.glUseProgram(shaderProgram);
        GLES30.glBindVertexArray(vaoList.get(0));
        {
            // MVP Matrix
            mvpMatrixLocation = GLES30.glGetUniformLocation(shaderProgram, "uMVPMatrix");
            GLES30.glUniformMatrix4fv(mvpMatrixLocation, 1, false, mvpMatrix, 0);
            // Draw
            GLES30.glDrawArrays(GLES30.GL_TRIANGLES, 0, VERTEX_COUNT);
        }
        GLES30.glBindVertexArray(0);
    }
}

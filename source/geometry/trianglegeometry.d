/// Triangle Creation
module trianglegeometry;

import bindbc.opengl;
import std.stdio;
import geometry;
import vec;
import error;
import parser;

/// Geometry stores all of the vertices and/or indices for a 3D object.
/// Geometry also has the responsibility of setting up the 'attributes'
class SurfaceTriangle: ISurface{
    GLuint mVBO;
    size_t mTriangles;

    /// Geometry data
    this(GLfloat[] vbo){
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render(){
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES,0,cast(int) mTriangles);
    }

    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo){
        // Compute the number of traingles.
        // Note: 6 floats per vertex, is why we are dividing by 6
        mTriangles = vbo.length / 6;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length* GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F3F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F3F();
    }
}

/// Stores triangles that also have texture coordinates
class SurfaceTexturedTriangle: ISurface{
    GLuint mVBO;
    size_t mTriangles;

    /// Geometry data
    this(GLfloat[] vbo){
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render(){
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES,0,cast(int) mTriangles);
    }

    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo){

        // Compute the number of traingles.
        // Note: 5 floats per vertex, is why we are dividing by 5
        mTriangles = vbo.length / 5;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length* GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F2F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F2F();
    }
}

/// Stores triangles that also have texture coordinates, normals, bitangents, and tangents
class SurfaceNormalMappedTriangle: ISurface{
    GLuint mVBO;
    size_t mTriangles;

    /// Geometry data
    this(GLfloat[] vbo){
        MakeTriangleFactory(vbo);
    }

    /// Render our geometry
    override void Render(){
        // Bind to our geometry that we want to draw
        glBindVertexArray(mVAO);
        // Call our draw call
        glDrawArrays(GL_TRIANGLES,0,cast(int) mTriangles);
    }

    /// Setup MeshNode as a Triangle
    void MakeTriangleFactory(GLfloat[] vbo){

        // Compute the number of traingles.
        // Note: 14 floats per vertex, is why we are dividing by 14
        mTriangles = vbo.length / 14;

        // Vertex Arrays Object (VAO) Setup
        glGenVertexArrays(1, &mVAO);
        // We bind (i.e. select) to the Vertex Array Object (VAO) that we want to work withn.
        glBindVertexArray(mVAO);

        // Vertex Buffer Object (VBO) creation
        glGenBuffers(1, &mVBO);
        glBindBuffer(GL_ARRAY_BUFFER, mVBO);
        glBufferData(GL_ARRAY_BUFFER, vbo.length* GLfloat.sizeof, vbo.ptr, GL_STATIC_DRAW);

        // Function call to setup attributes
        SetVertexAttributes!VertexFormat3F2F3F3F3F();

        // Unbind our currently bound Vertex Array Object
        glBindVertexArray(0);

        // Turn off attributes
        DisableVertexAttributes!VertexFormat3F2F();
    }
}


/// Helper function to return a textured quad
SurfaceTexturedTriangle MakeTexturedQuad(){
	return new SurfaceTexturedTriangle([
																				-1.0,1.0,0.0,  0.0,1.0,
																				-1.0,-1.0,0.0, 0.0,0.0,
																				1.0,-1.0,0.0,  1.0,0.0,
																				1.0,1.0,0.0, 1.0,1.0,
																				-1.0,1.0,0.0, 0.0,1.0,
																				1.0,-1.0,0.0, 1.0,0.0,
																		 ]
																		);
}

/// Helper function to return a textured quad with normals, binormals, and bitangents
SurfaceNormalMappedTriangle MakeTexturedNormalMappedQuad(P3DSlice slice){
    // takes the ratio of the height and the width
    int height = slice.getTexHeight();
    int width = slice.getTexWidth();
    float ratio = cast(float)height / cast(float)width;
    writeln("RATIO: ", ratio, " height: ", height, " width: ", width);
    // Define positions, UVs
    float heightAdjustment = 1;
	vec3 pos1 = vec3(-1.0,  ratio*heightAdjustment, 0.0);  // top-left
    vec3 pos2 = vec3(-1.0, -ratio*heightAdjustment, 0.0);  // bottom-left
    vec3 pos3 = vec3( 1.0, -ratio*heightAdjustment, 0.0);  // bottom-right
    vec3 pos4 = vec3( 1.0,  ratio*heightAdjustment, 0.0);  // top-right

    vec2 uv1 = vec2(0.0, 0.0); // top-left
    vec2 uv2 = vec2(0.0, 1.0); // bottom-left
    vec2 uv3 = vec2(1.0, 1.0); // bottom-right
    vec2 uv4 = vec2(1.0, 0.0); // top-right

	vec3 nm = vec3(0.0, 0.0, 1.0); // points up towards z, cam pos

	// 1 - 2 - 3 triangle
	vec3 edge1 = pos2 - pos1;
	vec3 edge2 = pos3 - pos1;
	vec2 deltaUV1 = uv2 - uv1;
	vec2 deltaUV2 = uv3 - uv1;

	float f = 1.0f / (deltaUV1.x * deltaUV2.y - deltaUV2.x * deltaUV1.y);

	vec3 tangent1;
    tangent1.x = f * (deltaUV2.y * edge1.x - deltaUV1.y * edge2.x);
    tangent1.y = f * (deltaUV2.y * edge1.y - deltaUV1.y * edge2.y);
    tangent1.z = f * (deltaUV2.y * edge1.z - deltaUV1.y * edge2.z);

    vec3 bitangent1;
    bitangent1.x = f * (-deltaUV2.x * edge1.x + deltaUV1.x * edge2.x);
    bitangent1.y = f * (-deltaUV2.x * edge1.y + deltaUV1.x * edge2.y);
    bitangent1.z = f * (-deltaUV2.x * edge1.z + deltaUV1.x * edge2.z);

	// 1 - 3 - 4 triangle
	vec3 edge3 = pos3 - pos1;
	vec3 edge4 = pos4 - pos1;
	vec2 deltaUV3 = uv3 - uv1;
	vec2 deltaUV4 = uv4 - uv1;

	vec3 tangent2;
    float f2 = 1.0f / (deltaUV3.x * deltaUV4.y - deltaUV4.x * deltaUV3.y);
    tangent2.x = f2 * (deltaUV4.y * edge3.x - deltaUV3.y * edge4.x);
    tangent2.y = f2 * (deltaUV4.y * edge3.y - deltaUV3.y * edge4.y);
    tangent2.z = f2 * (deltaUV4.y * edge3.z - deltaUV3.y * edge4.z);

    vec3 bitangent2;
    bitangent2.x = f2 * (-deltaUV4.x * edge3.x + deltaUV3.x * edge4.x);
    bitangent2.y = f2 * (-deltaUV4.x * edge3.y + deltaUV3.x * edge4.y);
    bitangent2.z = f2 * (-deltaUV4.x * edge3.z + deltaUV3.x * edge4.z);

	return new SurfaceNormalMappedTriangle([
		// 1 - 2 - 3 triangle
		pos1.x, pos1.y, pos1.z, uv1.x, uv1.y, nm.x, nm.y, nm.z, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
		pos2.x, pos2.y, pos2.z, uv2.x, uv2.y, nm.x, nm.y, nm.z, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,
		pos3.x, pos3.y, pos3.z, uv3.x, uv3.y, nm.x, nm.y, nm.z, tangent1.x, tangent1.y, tangent1.z, bitangent1.x, bitangent1.y, bitangent1.z,

		// 1 - 3 - 4 triangle
        pos4.x, pos4.y, pos4.z, uv4.x, uv4.y, nm.x, nm.y, nm.z, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z,
		pos1.x, pos1.y, pos1.z, uv1.x, uv1.y, nm.x, nm.y, nm.z, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z,
        pos3.x, pos3.y, pos3.z, uv3.x, uv3.y, nm.x, nm.y, nm.z, tangent2.x, tangent2.y, tangent2.z, bitangent2.x, bitangent2.y, bitangent2.z
	]);

	// return new SurfaceNormalMappedTriangle([
	// 																			-1.0,1.0,0.0,  0.0,1.0,     0,0,-1.0, 0,0,0, 0,0,0,
	// 																			-1.0,-1.0,0.0, 0.0,0.0,     0,0,-1.0, 0,0,0, 0,0,0,
	// 																			1.0,-1.0,0.0,  1.0,0.0,     0,0,-1.0, 0,0,0, 0,0,0,
	// 																			1.0,1.0,0.0,   1.0,1.0,     0,0,-1.0, 0,0,0, 0,0,0,
	// 																			-1.0,1.0,0.0,  0.0,1.0,     0,0,-1.0, 0,0,0, 0,0,0,
	// 																			1.0,-1.0,0.0,  1.0,0.0,     0,0,-1.0, 0,0,0, 0,0,0
	// 																	 ]
	// 																	);
}

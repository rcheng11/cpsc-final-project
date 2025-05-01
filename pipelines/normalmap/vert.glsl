#version 410 core

layout(location=0) in vec3 aPosition;
layout(location=1) in vec2 aTexCoords;
layout(location=2) in vec3 aNormal;
layout(location=3) in vec3 aTangent;
layout(location=4) in vec3 aBiTangent;

out VS_OUT {
    vec3 FragPos;
    vec2 TexCoords;
    mat3 TBN;
} vs_out;  

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProjection;

void main()
{
	// create out values
	vs_out.TexCoords = aTexCoords;
	vec3 FragPosWorld = vec3(uModel * vec4(aPosition, 1.0));
    vs_out.FragPos = FragPosWorld;

	vec4 finalPosition = uProjection * uView * uModel * vec4(aPosition,1.0f);

	// create TBN matrix
	vec3 T = normalize(vec3(uModel * vec4(aTangent, 0.0)));
	//vec3 B = normalize(vec3(uModel * vec4(aBiTangent, 0.0)));
	vec3 N = normalize(vec3(uModel * vec4(aNormal, 0.0)));
	vec3 B = normalize(cross(N, T)); 
	vs_out.TBN = transpose(mat3(T, B, N));

	// Note: Something subtle, but we need to use the finalPosition.w to do the perspective divide
	gl_Position = vec4(finalPosition.x, finalPosition.y, finalPosition.z, finalPosition.w);
}



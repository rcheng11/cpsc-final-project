#version 410 core

in VS_OUT {
    vec3 FragPos;
    vec2 TexCoords;
    mat3 TBN;
} fs_in; 

out vec4 fragColor;

uniform sampler2D albedomap;   // base color
uniform sampler2D normalmap;   // normal map

uniform vec3 lightPos;
uniform vec3 viewPos;

void main()
{

	// create normal using TBN to get into world coords
	vec3 normal = texture(normalmap, fs_in.TexCoords).rgb;
	normal = normal * 2.0 - 1.0;  
	//normal.r = normal.r * -1;
	//normal.g = normal.g * -1;
	normal = normalize(normal); 

	// actual color vals
    vec3 color = texture(albedomap, fs_in.TexCoords).rgb;

	// generate light source
    vec3 lightColor = vec3(1.0, 1.0, 1.0); // white light
    vec3 ambient = 0.3 * color;

    float distance = length(lightPos - fs_in.FragPos);
    float attenuation = 1.0 / (1.0 + 0.1 * distance + 0.05 * distance * distance);

    vec3 lightDir = fs_in.TBN * normalize(lightPos - fs_in.FragPos);
    float diff = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diff * lightColor * color * attenuation;

    vec3 viewDir = fs_in.TBN * normalize(viewPos - fs_in.FragPos);
	vec3 reflectDir = reflect(normalize(-lightDir), normal);
	float spec = pow(max(dot(viewDir, reflectDir), 0.0), 32.0);
    vec3 specular = 0.3 * spec * lightColor * diff;

    vec3 result = ambient + diffuse + specular;

    // sample alpha value, so not black
    float alpha = texture(albedomap, fs_in.TexCoords).a;
    fragColor = vec4(result, alpha);
}

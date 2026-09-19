shader_type spatial;
render_mode diffuse_burley, specular_toon;


// Material
uniform sampler2D albedo_texture : source_color;

uniform sampler2D normal_texture : hint_normal;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;

uniform sampler2D metallic_texture;
uniform float metallic_strength : hint_range(0.0, 1.0) = 0.0;

uniform sampler2D roughness_texture;
uniform float roughness_strength : hint_range(0.0, 1.0) = 0.0;

uniform float alpha_scissor_threshold : hint_range(0.0, 1.0) = 0.5;


// Cel Lighting
uniform vec3 tint_colour : source_color = vec3(1.0, 1.0, 1.0);

uniform vec3 shadow_tint : source_color = vec3(0.5, 0.5, 0.6);
uniform vec3 mid_tint : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 highlight_tint : source_color = vec3(1.0, 1.0, 1.0);

uniform float shadow_threshold : hint_range(0.0, 1.0) = 0.25;
uniform float highlight_threshold : hint_range(0.0, 1.0) = 0.9;

uniform float shadow_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float mid_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float highlight_intensity : hint_range(0.0, 1.0) = 0.7;


// Specular
uniform vec3 specular_tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float specular_threshold : hint_range(0.0, 1.0) = 0.8;
uniform float specular_intensity : hint_range(0.0, 2.0) = 0.0;


// Emission
uniform sampler2D emission_texture : source_color;
uniform vec3 emission_tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 0.0;


void fragment() {
	vec4 albedo = texture(albedo_texture, UV);
	
	ALBEDO = albedo.rgb * tint_colour;
	ALPHA = albedo.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	
	NORMAL_MAP = texture(normal_texture, UV).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
	
	METALLIC = texture(metallic_texture, UV).r * metallic_strength;
	
	ROUGHNESS = texture(roughness_texture, UV).r * roughness_strength;
	
	EMISSION = texture(emission_texture, UV).rgb * emission_tint * emission_strength;
}


void light() {
	float light_amount = max(dot(NORMAL, LIGHT), 0.0);
	
	vec3 cel_colour;
	
	if (light_amount < shadow_threshold) {
		cel_colour = ALBEDO * shadow_tint * shadow_intensity;
	}
	else if (light_amount < highlight_threshold) {
		cel_colour = ALBEDO * mid_tint * mid_intensity;
	}
	else {
		cel_colour = ALBEDO * highlight_tint * highlight_intensity;
	}
	
	// Diffuse lighting.
	DIFFUSE_LIGHT += cel_colour * LIGHT_COLOR * ATTENUATION * (1.0 - METALLIC);
	
	
	// Toon specular lighting.
	float specular_amount = max(dot(NORMAL, normalize(LIGHT + VIEW)), 0.0);
	float specular_power = mix(64.0, 4.0, ROUGHNESS);
	
	specular_amount = pow(specular_amount, specular_power);
	
	float roughness_threshold = mix(specular_threshold, 0.2, ROUGHNESS);
	
	if (specular_amount > roughness_threshold) {
		SPECULAR_LIGHT += specular_tint * LIGHT_COLOR * ATTENUATION * specular_intensity * METALLIC;
	}
}
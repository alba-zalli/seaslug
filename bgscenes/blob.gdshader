shader_type canvas_item;

uniform int OCTAVE = 3;
uniform float mulscale = 1.6;
uniform float timescale = 0.4;

uniform float blob_size = 0.35;
uniform float distortion = 0.25;

// New: 0 = original noisy blob, 1 = perfectly round blob.
uniform float smoothness : hint_range(0.0, 1.0) = 0.0;

uniform float edge_softness = 0.14;

uniform vec4 BLOB_COL : source_color = vec4(0.04, 0.38, 0.88, 1.0);

float rand(vec2 input){
	return fract(sin(dot(input, vec2(23.53, 44.0))) * 42350.45);
}

float perlin(vec2 input){
	vec2 i = floor(input);
	vec2 j = fract(input);
	vec2 coord = smoothstep(0.0, 1.0, j);

	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	return mix(
		mix(a, b, coord.x),
		mix(c, d, coord.x),
		coord.y
	);
}

mat2 octave_rotate(float a){
	float s = sin(a);
	float c = cos(a);
	return mat2(vec2(c, -s), vec2(s, c));
}

float fbm(vec2 input){
	float value = 0.0;
	float scale = 0.5;
	mat2 rot = octave_rotate(0.5);

	for(int i = 0; i < OCTAVE; i++){
		value += perlin(input) * scale;
		input = rot * input * 2.0 + vec2(17.3, 9.7);
		scale *= 0.5;
	}

	return value;
}

void fragment(){
	float newtime = TIME * timescale;

	vec2 centered = UV - vec2(0.5);
	float dist = length(centered);
	float angle = atan(centered.y, centered.x);

	// Seamless circular sampling.
	vec2 edge_coord = vec2(cos(angle), sin(angle)) * mulscale;
	edge_coord += vec2(0.2 * newtime, -0.15 * newtime);

	float n = fbm(edge_coord);

	float wobble = fbm(
		edge_coord * 0.5 +
		vec2(3.1, -1.7) +
		0.05 * newtime
	);

	// Original noisy edge.
	float noisy_edge = blob_size;
	noisy_edge += distortion * (n - 0.5) * 0.6;
	noisy_edge += distortion * (wobble - 0.5) * 0.4;

	// Blend toward a perfect circle.
	float edge = mix(noisy_edge, blob_size, smoothness);

	float alpha = smoothstep(edge, edge - edge_softness, dist);

	COLOR = vec4(BLOB_COL.rgb, BLOB_COL.a * alpha);
}
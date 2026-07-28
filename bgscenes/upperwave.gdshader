// Made by PWira // MIT License
shader_type canvas_item;

// Floating boat
uniform sampler2D boat_texture : source_color;
uniform bool show_boat = true;
uniform vec2 boat_position = vec2(0.5, 0.2);
uniform float boat_scale : hint_range(0.01, 2.0) = 0.2;
uniform float boat_float_offset : hint_range(-0.1, 0.1) = 0.0;
uniform float boat_wave_multiplier : hint_range(0.0, 5.0) = 1.0;


// Liquid Property
uniform float liquid_level : hint_range(0.0, 1.0) = 0.5;
uniform vec4 liquid_color : source_color = vec4(0.2, 0.5, 1.0, 0.8);
uniform vec4 foam_color : source_color = vec4(0.8, 0.9, 1.0, 0.6);


// Shading Property
uniform vec4 shade_dark_color : source_color = vec4(0.05, 0.15, 0.4, 1.0);
uniform vec4 shade_light_color : source_color = vec4(0.6, 0.85, 1.0, 1.0);
uniform float shade_noise_scale : hint_range(0.1, 20.0) = 3.0;
uniform float shade_noise_speed : hint_range(0.0, 2.0) = 0.15;
uniform float shade_strength : hint_range(0.0, 1.0) = 0.6;


// Wave property
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 20.0) = 5.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;


// Gravity
uniform float gravity_angle : hint_range(-3.14159, 3.14159) = 0.0;
uniform vec2 gravity_direction = vec2(0.0, 1.0);


// Visual property
uniform float foam_thickness : hint_range(0.0, 0.1) = 0.02;
uniform float shine_intensity : hint_range(0.0, 1.0) = 0.3;

uniform bool add_bubble = true;
uniform float bubble_scale : hint_range(0.0, 50.0) = 10.0;
uniform float bubble_speed : hint_range(0.0, 2.0) = 0.5;


// Simple Noise
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}


float noise(vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);

	float a = random(i);
	float b = random(i + vec2(1.0,0.0));
	float c = random(i + vec2(0.0,1.0));
	float d = random(i + vec2(1.0,1.0));

	vec2 u = f*f*(3.0-2.0*f);

	return mix(a,b,u.x)
		+ (c-a)*u.y*(1.0-u.x)
		+ (d-b)*u.x*u.y;
}


// FBM noise
float fbm(vec2 st) {

	float value = 0.0;
	float amplitude = 0.5;

	mat2 rot = mat2(
		vec2(0.8,0.6),
		vec2(-0.6,0.8)
	);

	for(int i = 0; i < 4; i++) {

		value += amplitude * noise(st);

		st = rot * st * 2.0 + vec2(17.0,31.0);

		amplitude *= 0.5;
	}

	return value;
}


vec2 rotate(vec2 v,float angle) {

	float c = cos(angle);
	float s = sin(angle);

	return vec2(
		v.x*c-v.y*s,
		v.x*s+v.y*c
	);
}



void fragment() {


	vec2 uv = UV;


	vec2 centered_uv = uv - 0.5;

	vec2 rotated_uv = rotate(
		centered_uv,
		-gravity_angle
	);

	rotated_uv += 0.5;



	// Main wave
	float wave = sin(
		rotated_uv.x * wave_frequency +
		TIME * wave_speed
	) * wave_amplitude;


	float surface_y = (1.0-liquid_level)+wave;



	// WATER
	if(rotated_uv.y > surface_y) {


		vec4 base_color = liquid_color;


		float internal_wave =
			fbm(
				vec2(
					rotated_uv.x*3.0,
					rotated_uv.y*3.0 + TIME*0.5
				)
			)*0.1;


		base_color.rgb += vec3(internal_wave);



		if(add_bubble) {

			vec2 bubble_uv = rotated_uv*bubble_scale;

			bubble_uv.y += TIME*bubble_speed;

			float bubble_noise = fbm(bubble_uv);

			float bubbles =
				smoothstep(
					0.93,
					1.0,
					bubble_noise
				);

			base_color.rgb += vec3(bubbles*0.3);
		}



		float shine =
			pow(
				1.0-abs(uv.x-0.5)*2.0,
				3.0
			)*shine_intensity;


		base_color.rgb += vec3(shine);



		float depth_factor =
			1.0 -
			(rotated_uv.y-surface_y)
			/
			(1.0-surface_y);



		float shade_n =
			fbm(
				vec2(
					rotated_uv.x*shade_noise_scale,
					rotated_uv.y*shade_noise_scale+
					TIME*shade_noise_speed
				)
			);


		float shade_mix =
			clamp(
				depth_factor*0.5+
				shade_n*0.5,
				0.0,
				1.0
			);


		vec3 shading =
			mix(
				shade_dark_color.rgb,
				shade_light_color.rgb,
				shade_mix
			);


		base_color.rgb =
			mix(
				base_color.rgb,
				base_color.rgb*shading,
				shade_strength
			);


		COLOR = base_color;



	}
	else if(rotated_uv.y > surface_y-foam_thickness) {


		float foam_factor =
			(surface_y-rotated_uv.y)
			/
			foam_thickness;


		float foam_noise =
			fbm(
				vec2(
					rotated_uv.x*20.0,
					TIME*2.0
				)
			);


		foam_factor *= foam_noise;


		COLOR =
			mix(
				liquid_color,
				foam_color,
				foam_factor
			);


	}
	else {

		COLOR = vec4(0.0);

	}



	// =========================
	// FLOATING BOAT
	// =========================

	if(show_boat) {


		float boat_wave =
			sin(
				(boat_position.x-0.5)
				*
				wave_frequency
				+
				TIME*wave_speed
			)
			*
			wave_amplitude
			*
			boat_wave_multiplier;



		vec2 floating_position = boat_position;

		floating_position.y +=
			boat_wave +
			boat_float_offset;



		vec2 boat_uv =
			(uv-floating_position)
			/
			boat_scale
			+
			0.5;



		if(
			boat_uv.x >= 0.0 &&
			boat_uv.x <= 1.0 &&
			boat_uv.y >= 0.0 &&
			boat_uv.y <= 1.0
		) {


			vec4 boat =
				texture(
					boat_texture,
					boat_uv
				);


			if(boat.a > 0.0) {

				COLOR = boat;

			}

		}

	}

}
// Made by PWira // MIT License
shader_type canvas_item;

// Liquid Property
uniform float liquid_level : hint_range(0.0, 1.0) = 0.5;
uniform vec4 liquid_color : source_color = vec4(0.2, 0.5, 1.0, 0.8);
uniform vec4 foam_color : source_color = vec4(0.8, 0.9, 1.0, 0.6);

// Floating object
uniform sampler2D boat_texture;
uniform bool show_boat = true;
uniform vec2 boat_position = vec2(0.5, 0.2);
uniform float boat_scale : hint_range(0.01, 2.0) = 0.2;
uniform float boat_float_offset : hint_range(-0.1, 0.1) = 0.0;
uniform vec4 boat_shadow_color : source_color = vec4(0.0, 0.05, 0.1, 0.35);
uniform float boat_shadow_scale : hint_range(0.5, 3.0) = 1.4;   // size relative to boat_scale
uniform float boat_shadow_flatten : hint_range(0.15, 1.0) = 0.4; // <1 squashes it into a flat ellipse
uniform float boat_shadow_softness : hint_range(0.0, 1.0) = 0.6; // edge falloff
uniform float boat_shadow_y_offset : hint_range(-0.2, 0.2) = 0.04; // nudge shadow toward the waterline
// Pixel size of the node this shader is drawn on. Canvas_item shaders have
// no built-in way to know this, so it must be pushed from a script, e.g.:
//   material.set_shader_parameter("rect_size", size)
// Update it whenever the node resizes, or the boat will re-stretch.
uniform vec2 rect_size = vec2(1.0, 1.0);

// Shading Property (dark / light shading of the liquid body)
uniform vec4 shade_dark_color : source_color = vec4(0.05, 0.15, 0.4, 1.0);
uniform vec4 shade_light_color : source_color = vec4(0.6, 0.85, 1.0, 1.0);
uniform float shade_noise_scale : hint_range(0.1, 20.0) = 3.0;
uniform float shade_noise_speed : hint_range(0.0, 2.0) = 0.15;
uniform float shade_strength : hint_range(0.0, 1.0) = 0.6; // how much the shading tints the liquid

// Wave property
uniform float wave_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(0.0, 20.0) = 5.0;
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;

// Gravity property
uniform float gravity_angle : hint_range(-3.14159, 3.14159) = 0.0; // rotate in radian
uniform vec2 gravity_direction = vec2(0.0, 1.0);

// Visual property
uniform float foam_thickness : hint_range(0.0, 0.1) = 0.02;
uniform float shine_intensity : hint_range(0.0, 1.0) = 0.3;
uniform bool add_bubble = true;
uniform float bubble_scale : hint_range(0.0, 50.0) = 10.0;
uniform float bubble_speed : hint_range(0.0, 2.0) = 0.5;

// Reflection / sparkle property (NEW)
uniform float shine_noise_scale : hint_range(1.0, 60.0) = 18.0;   // size of the shimmer cells
uniform vec2 shine_scroll_speed = vec2(0.12, -0.2);                // direction/speed noise drifts
uniform float shine_sparkle_threshold : hint_range(0.5, 0.99) = 0.8; // higher = fewer, sharper glints
uniform float shine_sparkle_softness : hint_range(0.001, 0.3) = 0.08; // edge softness of glints
uniform float shine_band_strength : hint_range(0.0, 1.0) = 0.5;    // how much of the soft base highlight remains

// Simple Noise
float random(vec2 st) {
	return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 st) {
	vec2 i = floor(st);
	vec2 f = fract(st);
	float a = random(i);
	float b = random(i + vec2(1.0, 0.0));
	float c = random(i + vec2(0.0, 1.0));
	float d = random(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion - layers several rotated/offset noise octaves
// so the result doesn't align to a visible grid (the source of the
// "square" artifacts in the single-octave version).
float fbm(vec2 st) {
	float value = 0.0;
	float amplitude = 0.5;
	// small fixed rotation per octave to de-align the grids
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	for (int i = 0; i < 4; i++) {
		value += amplitude * noise(st);
		st = rot * st * 2.0 + vec2(17.0, 31.0);
		amplitude *= 0.5;
	}
	return value;
}

vec2 rotate(vec2 v, float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void fragment() {
	vec2 uv = UV;
	vec2 centered_uv = uv - 0.5;
	vec2 rotated_uv = rotate(centered_uv, -gravity_angle);
	rotated_uv += 0.5;

	// Wave based on X in gravity coordinate
	float wave = sin(rotated_uv.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
	float surface_y = (1.0 - liquid_level) + wave;

	// Shared boat placement math: computed once here so the shadow (drawn
	// on the water below) and the boat sprite (drawn on top later) always
	// agree on exactly where the boat is, and never drift apart.
	float aspect = rect_size.x / rect_size.y;
	vec2 boat_centered = boat_position - 0.5;
	vec2 boat_rotated = rotate(boat_centered, -gravity_angle) + 0.5;
	float boat_wave = sin(boat_rotated.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
	vec2 boat_screen_pos = boat_position + vec2(0.0, boat_wave + boat_float_offset);
	
	if (rotated_uv.y > surface_y) {
		vec4 base_color = liquid_color;

		// Internal movement, now using fbm to avoid blocky patterning
		float internal_wave = fbm(vec2(rotated_uv.x * 3.0, rotated_uv.y * 3.0 + TIME * 0.5)) * 0.1;
		base_color.rgb += vec3(internal_wave);

		if (add_bubble) {
			vec2 bubble_uv = rotated_uv * bubble_scale;
			bubble_uv.y += TIME * bubble_speed;
			float bubble_noise = fbm(bubble_uv);
			// smoothstep instead of step -> soft round-edged bubbles
			// instead of hard-edged grid-cell squares
			float bubbles = smoothstep(0.93, 1.0, bubble_noise);
			base_color.rgb += vec3(bubbles * 0.3);
		}

		// --- Animated light reflection (replaces static gradient shine) ---
		// Soft base band: still brighter near the horizontal center, but
		// weighted down so it reads as ambient light rather than the whole effect.
		float shine_band = pow(1.0 - abs(uv.x - 0.5) * 2.0, 3.0) * shine_band_strength;

		// A scrolling noise field standing in for the surface's constantly
		// shifting micro-ripples. Sampled in the gravity-aligned space so
		// glints stay correct relative to the liquid surface, not the screen.
		vec2 shine_uv = rotated_uv * shine_noise_scale + TIME * shine_scroll_speed;
		float shine_noise = fbm(shine_uv);

		// Push the noise through a tight smoothstep so it breaks up into
		// small bright glints instead of a smooth blob - like light
		// catching individual ripple facets.
		float sparkle = smoothstep(
			shine_sparkle_threshold - shine_sparkle_softness,
			shine_sparkle_threshold + shine_sparkle_softness,
			shine_noise
		);

		// Glints are strongest where the soft band is already bright,
		// so reflections concentrate near the "sun path" instead of
		// appearing uniformly across the whole surface.
		float shine = (shine_band + sparkle * (shine_band * 0.7 + 0.3)) * shine_intensity;
		base_color.rgb += vec3(shine);

		// Soft shadow cast by the boat onto the water surface. Uses the
		// same boat_screen_pos/aspect as the boat sprite draw below so it
		// always tracks the hull exactly, flattened into an ellipse and
		// nudged slightly toward the waterline.
		if (show_boat) {
			vec2 shadow_offset = uv - (boat_screen_pos + vec2(0.0, boat_shadow_y_offset));
			shadow_offset.x *= aspect;
			shadow_offset.y /= boat_shadow_flatten;
			float shadow_dist = length(shadow_offset) / (boat_scale * boat_shadow_scale);
			float shadow_factor = 1.0 - smoothstep(1.0 - boat_shadow_softness, 1.0, shadow_dist);
			base_color.rgb = mix(base_color.rgb, boat_shadow_color.rgb, shadow_factor * boat_shadow_color.a);
		}

		// Depth-based blend factor
		float depth_factor = 1.0 - (rotated_uv.y - surface_y) / (1.0 - surface_y);

		// Noise-driven dark/light shading using the two new color uniforms,
		// blended with depth so it still reads as "darker deeper" while
		// being broken up organically instead of a flat multiply.
		float shade_n = fbm(vec2(rotated_uv.x * shade_noise_scale,
								  rotated_uv.y * shade_noise_scale + TIME * shade_noise_speed));
		float shade_mix = clamp(depth_factor * 0.5 + shade_n * 0.5, 0.0, 1.0);
		vec3 shading = mix(shade_dark_color.rgb, shade_light_color.rgb, shade_mix);

		base_color.rgb = mix(base_color.rgb, base_color.rgb * shading, shade_strength);

		COLOR = base_color;
	} else if (rotated_uv.y > surface_y - foam_thickness) {
		float foam_factor = (surface_y - rotated_uv.y) / foam_thickness;
		float foam_noise = fbm(vec2(rotated_uv.x * 20.0, TIME * 2.0));
		foam_factor *= foam_noise;
		vec4 final_foam = mix(liquid_color, foam_color, foam_factor);
		COLOR = final_foam;
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}

	// Draw floating boat last, on top of whatever liquid/foam/transparent
	// color was just written, so it can never get overwritten regardless
	// of where it sits relative to the surface.
	if (show_boat) {
		// Correct for the node's aspect ratio so the boat isn't stretched
		// horizontally on non-square canvases. rect_size must be set from
		// a script (see uniform declaration above).
		//
		// Use boat_screen_pos (already includes the wave + float offset,
		// shifted in plain screen space) instead of offsetting boat_uv.y
		// directly - offsetting boat_uv.y after the divide by boat_scale
		// silently flips the sign and rescales the motion, which is why
		// the boat and its shadow were drifting out of phase.
		vec2 uv_offset = uv - boat_screen_pos;
		uv_offset.x *= aspect;

		vec2 boat_uv = uv_offset / boat_scale + 0.5;

		if (boat_uv.x >= 0.0 && boat_uv.x <= 1.0 &&
			boat_uv.y >= 0.0 && boat_uv.y <= 1.0) {

			vec4 boat = texture(boat_texture, boat_uv);

			// Alpha-blend instead of a hard overwrite, so soft/antialiased
			// edges on the boat sprite blend cleanly into the water.
			COLOR = mix(COLOR, boat, boat.a);
		}
	}
}

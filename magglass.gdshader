shader_type canvas_item;

// Controls the zoom
uniform float radius : hint_range(0.0, 5.0, 0.01) = 5;
// Controls the intensity of the distortion (higher values = more distortion)
uniform float power : hint_range(0.01, 3.0, 0.01) = 0.2;
// If true, color will be set directly, if false, color will be multiplied (for colored lenses)
uniform bool transparent_texture = true;
// This gives us access to the screen texture so we can warp it
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// --- mask controls ---
uniform float mask_radius : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float mask_feather : hint_range(0.0, 0.2, 0.001) = 0.02;

// This will store the center position of the effect on the screen
varying vec2 screen_center;

void vertex() {
    // Convert the object's position to screen space
    screen_center = (CANVAS_MATRIX * MODEL_MATRIX[3]).xy;
}

void fragment() {
    vec2 uv = SCREEN_UV; // Get the current pixel's UV coordinates
    vec2 centerUV = screen_center * SCREEN_PIXEL_SIZE; // Convert the center to UV space
    // Adjust for aspect ratio to prevent oval distortion
    vec2 aspect_ratio = vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
    vec2 adjusted_uv = (uv - centerUV) * aspect_ratio + centerUV;
    // Calculate distance from the effect center
    float dist = distance(centerUV, adjusted_uv);

    // Compute warp intensity based on distance and power setting
    float warp = clamp(1.0 - pow(dist / radius, power), 0.0, 1.0);

    // Apply the distortion effect by pulling UVs towards the center
    vec2 warped_uv = uv + (centerUV - uv) * warp;
    // Sample the screen texture at the new warped UVs
    vec4 tex_color = texture(SCREEN_TEXTURE, warped_uv);

    // If transparent_texture is true, directly set the color, otherwise multiply the color
    if (transparent_texture) {
        COLOR = tex_color;
    } else {
        COLOR *= tex_color;
    }

    // --- circular mask, based on the sprite's own quad UV ---
    float mask_dist = distance(UV, vec2(0.5));
    float mask = 1.0 - smoothstep(mask_radius - mask_feather, mask_radius, mask_dist);
    COLOR.a *= mask;
}
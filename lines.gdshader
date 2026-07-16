shader_type canvas_item;

uniform float desaturate : hint_range(0.0, 1.0) = 0.6;
uniform float contrast_reduce : hint_range(0.0, 1.0) = 0.4;
uniform float darken : hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 desat = mix(tex.rgb, vec3(gray), desaturate);
    desat = mix(vec3(0.5), desat, 1.0 - contrast_reduce); // pull toward mid-gray
    desat *= (1.0 - darken);
    COLOR = vec4(desat, tex.a);
}
shader_type canvas_item;
uniform float dissolve_amount : hint_range(0.0,1.0) = 0.0;
uniform sampler2D noise_texture : source_color;

varying flat vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float noise_val = texture(noise_texture, UV).r;
    if (noise_val < dissolve_amount) {
        discard;
    }
    COLOR = tex * modulate;
}

shader_type canvas_item;

uniform bool enabled = false;


void fragment() {
	if (enabled) {
	    vec4 tex_color = texture(TEXTURE, UV);
	    
	    if (tex_color.a > 0.0) {
	        COLOR = vec4(1.0, 1.0, 1.0, tex_color.a);
	    } else {
	        COLOR = tex_color;
	    }
	}
}
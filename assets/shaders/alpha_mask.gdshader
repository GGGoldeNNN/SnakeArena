shader_type canvas_item;

uniform sampler2D mask : source_color;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask_color = texture(mask, UV);
	COLOR = vec4(color.rgb, color.a * mask_color.a);
}

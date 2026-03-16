shader_type canvas_item;

uniform float fill_level : hint_range(0.0, 1.0) = 1.0;
uniform vec4 liquid_color : source_color = vec4(0.78, 0.08, 0.08, 1.0);
uniform vec4 empty_color : source_color = vec4(0.10, 0.01, 0.01, 1.0);
uniform vec4 rim_color : source_color = vec4(0.50, 0.14, 0.14, 1.0);

void fragment() {
	vec2 centered = UV * 2.0 - 1.0;
	float dist = length(centered);

	if (dist > 1.0) {
		COLOR = vec4(0.0);
	} else {
		bool is_rim = dist > 0.88;
		float surface = 1.0 - fill_level;
		float wave = sin(UV.x * 28.0) * 0.018 * (1.0 - dist);
		bool is_liquid = (UV.y - wave) > surface;

		vec4 base;
		if (is_rim) {
			base = rim_color;
		} else if (is_liquid) {
			base = liquid_color;
		} else {
			base = empty_color;
		}

		float highlight = smoothstep(0.55, 0.0, dist) * smoothstep(0.15, -0.5, centered.x + centered.y);
		base.rgb += vec3(highlight * 0.3);
		float depth = smoothstep(1.0, 0.65, dist);
		base.rgb *= mix(0.65, 1.0, depth);

		COLOR = base;
	}
}

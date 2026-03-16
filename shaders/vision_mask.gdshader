shader_type canvas_item;

// Player position in screen pixel coordinates, updated every frame from GDScript
uniform vec2 player_screen_pos = vec2(320.0, 180.0);

// Inner radius: within this distance the world is fully visible
uniform float inner_radius : hint_range(0.0, 500.0) = 100.0;

// Outer radius: beyond this distance is full darkness
uniform float outer_radius : hint_range(0.0, 800.0) = 260.0;

// The darkness color - slight blue tint for atmosphere
uniform vec4 fog_color : source_color = vec4(0.02, 0.02, 0.06, 1.0);

void fragment() {
	float dist = length(FRAGCOORD.xy - player_screen_pos);
	float alpha = smoothstep(inner_radius, outer_radius, dist);
	COLOR = vec4(fog_color.rgb, alpha);
}

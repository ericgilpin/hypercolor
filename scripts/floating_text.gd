class_name FloatingText
extends Node2D

# Spawn floating text at a world position.
# Usage: FloatingText.spawn(get_parent(), "Miss", Color.WHITE, global_position)
static func spawn(parent: Node, text: String, color: Color, world_position: Vector2) -> void:
	var instance = FloatingText.new()
	parent.add_child(instance)
	instance.global_position = world_position
	instance._animate(text, color)


func _animate(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-32, -64)
	add_child(label)

	var drift = Vector2(randf_range(-20.0, 20.0), -80.0)

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position", position + drift, 0.75)
	tween.tween_property(self, "modulate:a", 0.0, 0.75)
	tween.chain().tween_callback(queue_free)

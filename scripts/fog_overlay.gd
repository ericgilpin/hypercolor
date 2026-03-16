extends CanvasLayer

@onready var overlay: ColorRect = $ColorRect

var player: Node2D


func initialize(player_node: Node2D) -> void:
	player = player_node


func _process(_delta: float) -> void:
	if not player:
		return

	# Convert the player's world position to screen pixel coordinates
	var screen_pos = get_viewport().get_canvas_transform() * player.global_position
	overlay.material.set_shader_parameter("player_screen_pos", screen_pos)

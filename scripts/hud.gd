extends CanvasLayer

const ORB_SIZE = 58
const ORB_SHADER = preload("res://shaders/orb.gdshader")

var player: Entity

var _life_material: ShaderMaterial
var _mana_material: ShaderMaterial
var _life_label: Label
var _mana_label: Label


func _ready() -> void:
	layer = 10
	_build()


func initialize(player_node: Entity) -> void:
	player = player_node


func _process(_delta: float) -> void:
	if not player:
		return

	var life_fraction = float(player.current_life) / float(player.max_life)
	var mana_fraction = float(player.current_mana) / float(player.max_mana)

	_life_material.set_shader_parameter("fill_level", life_fraction)
	_mana_material.set_shader_parameter("fill_level", mana_fraction)
	_life_label.text = "%d" % player.current_life
	_mana_label.text = "%d" % player.current_mana


func _build() -> void:
	# Life orb — bottom left corner
	_life_material = _make_orb_material(
		Color(0.78, 0.08, 0.08),   # red liquid
		Color(0.10, 0.01, 0.01),   # dark red empty
		Color(0.50, 0.14, 0.14)    # rim
	)
	var life_orb = _make_orb_rect(_life_material)
	life_orb.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	life_orb.set_offset(SIDE_LEFT, 8)
	life_orb.set_offset(SIDE_BOTTOM, -8)
	life_orb.set_offset(SIDE_RIGHT, 8 + ORB_SIZE)
	life_orb.set_offset(SIDE_TOP, -8 - ORB_SIZE)
	add_child(life_orb)

	_life_label = _make_orb_label()
	_life_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_life_label.set_offset(SIDE_LEFT, 8)
	_life_label.set_offset(SIDE_BOTTOM, -8 - ORB_SIZE - 2)
	_life_label.set_offset(SIDE_RIGHT, 8 + ORB_SIZE)
	_life_label.set_offset(SIDE_TOP, -8 - ORB_SIZE - 18)
	add_child(_life_label)

	# Mana orb — bottom right corner
	_mana_material = _make_orb_material(
		Color(0.08, 0.20, 0.85),   # blue liquid
		Color(0.01, 0.03, 0.12),   # dark blue empty
		Color(0.14, 0.22, 0.52)    # rim
	)
	var mana_orb = _make_orb_rect(_mana_material)
	mana_orb.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	mana_orb.set_offset(SIDE_RIGHT, -8)
	mana_orb.set_offset(SIDE_BOTTOM, -8)
	mana_orb.set_offset(SIDE_LEFT, -8 - ORB_SIZE)
	mana_orb.set_offset(SIDE_TOP, -8 - ORB_SIZE)
	add_child(mana_orb)

	_mana_label = _make_orb_label()
	_mana_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_mana_label.set_offset(SIDE_RIGHT, -8)
	_mana_label.set_offset(SIDE_BOTTOM, -8 - ORB_SIZE - 2)
	_mana_label.set_offset(SIDE_LEFT, -8 - ORB_SIZE)
	_mana_label.set_offset(SIDE_TOP, -8 - ORB_SIZE - 18)
	add_child(_mana_label)


func _make_orb_material(liquid: Color, empty: Color, rim: Color) -> ShaderMaterial:
	var mat = ShaderMaterial.new()
	mat.shader = ORB_SHADER
	mat.set_shader_parameter("liquid_color", liquid)
	mat.set_shader_parameter("empty_color", empty)
	mat.set_shader_parameter("rim_color", rim)
	mat.set_shader_parameter("fill_level", 1.0)
	return mat


func _make_orb_rect(mat: ShaderMaterial) -> ColorRect:
	var rect = ColorRect.new()
	rect.custom_minimum_size = Vector2(ORB_SIZE, ORB_SIZE)
	rect.material = mat
	return rect


func _make_orb_label() -> Label:
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	return label

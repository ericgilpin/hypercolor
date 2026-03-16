class_name Enemy
extends Entity

const MOVE_SPEED = 55.0
const AGGRO_RANGE = 180.0
const ATTACK_RANGE = 36.0

enum State { IDLE, CHASE, ATTACK }

var state: State = State.IDLE
var player: Entity = null


func _init_stats() -> void:
	stat_strength = 15
	stat_dexterity = 10
	stat_vitality = 12
	stat_energy = 0
	base_damage_min = 1
	base_damage_max = 4
	base_attack_rating = 40
	base_defense = 8
	attack_cooldown = 1.4


func _ready() -> void:
	super._ready()
	# Allow this node to receive mouse input events via its Area2D child
	$ClickArea.input_event.connect(_on_click_area_input_event)


func initialize(player_node: Entity) -> void:
	player = player_node


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not is_alive or not player:
		return

	_update_state()
	_process_state()


func _update_state() -> void:
	var dist = global_position.distance_to(player.global_position)
	match state:
		State.IDLE:
			if dist < AGGRO_RANGE:
				state = State.CHASE
		State.CHASE:
			if dist <= ATTACK_RANGE:
				state = State.ATTACK
			elif dist > AGGRO_RANGE * 1.5:
				state = State.IDLE
		State.ATTACK:
			if dist > ATTACK_RANGE:
				state = State.CHASE


func _process_state() -> void:
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.CHASE:
			velocity = (player.global_position - global_position).normalized() * MOVE_SPEED
		State.ATTACK:
			velocity = Vector2.ZERO
			attack(player)
	move_and_slide()


func _die() -> void:
	super._die()
	queue_free()


# When the player left-clicks on this enemy, tell the player to target us
func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if player and player.has_method("set_attack_target"):
				player.set_attack_target(self)
				# Consume the event so the player doesn't also move to this position
				get_viewport().set_input_as_handled()

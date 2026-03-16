extends Entity

const MOVE_SPEED = 120.0
const ATTACK_RANGE = 40.0
const ARRIVAL_THRESHOLD = 4.0

var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var attack_target: Entity = null


func _ready() -> void:
	# Set warrior-class starting stats before calling super,
	# since super._ready() initializes current_health from stat_vitality
	stat_strength = 30
	stat_dexterity = 20
	stat_vitality = 25
	stat_energy = 10
	base_damage_min = 3
	base_damage_max = 8
	base_attack_rating = 80
	base_defense = 15
	attack_cooldown = 0.7
	super._ready()
	$Camera2D.make_current()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Left-click on ground to move - cancel any attack target
			attack_target = null
			target_position = get_global_mouse_position()
			is_moving = true


func _physics_process(delta: float) -> void:
	super._physics_process(delta)  # keeps the attack timer ticking

	if attack_target:
		_handle_attack_movement()
	elif is_moving:
		_handle_movement()
	else:
		velocity = Vector2.ZERO
		move_and_slide()


# Called by enemy when the player left-clicks on it
func set_attack_target(target: Entity) -> void:
	attack_target = target
	is_moving = false


func _handle_attack_movement() -> void:
	if not is_instance_valid(attack_target) or not attack_target.is_alive:
		attack_target = null
		return

	var dist = global_position.distance_to(attack_target.global_position)
	if dist <= ATTACK_RANGE:
		velocity = Vector2.ZERO
		attack(attack_target)
	else:
		velocity = (attack_target.global_position - global_position).normalized() * MOVE_SPEED

	move_and_slide()


func _handle_movement() -> void:
	var direction = target_position - global_position
	if direction.length() <= ARRIVAL_THRESHOLD:
		is_moving = false
		velocity = Vector2.ZERO
	else:
		velocity = direction.normalized() * MOVE_SPEED
	move_and_slide()

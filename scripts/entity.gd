class_name Entity
extends CharacterBody2D

# D2-style core stats
@export var stat_strength: int = 10
@export var stat_dexterity: int = 10
@export var stat_vitality: int = 10
@export var stat_energy: int = 10

var level: int = 1
var current_life: int
var current_mana: int
var is_alive: bool = true

# Base combat values - subclasses set these to define character type and equipped gear
var base_damage_min: int = 1
var base_damage_max: int = 4
var base_attack_rating: int = 50
var base_defense: int = 10
var attack_cooldown: float = 1.0

var _attack_timer: float = 0.0
var _flash_tween: Tween

# --- Derived stats ---

var max_life: int:
	get: return stat_vitality * 4

var max_mana: int:
	get: return stat_energy * 3

# Attack rating: base + 5 per DEX point (affects hit chance)
var attack_rating: int:
	get: return base_attack_rating + (stat_dexterity * 5)

# Defense: base + 1 per 2 DEX points (affects chance of being hit)
var defense: int:
	get: return base_defense + int(stat_dexterity / 2.0)

# Damage range: STR adds to max damage (1 extra per 2 STR above 10)
var damage_min: int:
	get: return base_damage_min

var damage_max: int:
	get: return base_damage_max + maxi(0, int((stat_strength - 10) / 2.0))


func _ready() -> void:
	_init_stats()
	current_life = max_life
	current_mana = max_mana


# Override in subclasses to set stat_ and base_ values before life/mana are computed
func _init_stats() -> void:
	pass


func _physics_process(delta: float) -> void:
	if _attack_timer > 0.0:
		_attack_timer -= delta


# D2 hit chance formula: AR vs Defense, clamped to 5%-95%
func calculate_hit_chance(target: Entity) -> float:
	var ar = float(attack_rating)
	var dr = float(target.defense)
	return clampf(ar / (ar + dr) * 100.0, 5.0, 95.0)


func roll_to_hit(target: Entity) -> bool:
	return randf() * 100.0 < calculate_hit_chance(target)


func roll_damage() -> int:
	return randi_range(damage_min, damage_max)


func can_attack() -> bool:
	return is_alive and _attack_timer <= 0.0


func attack(target: Entity) -> void:
	if not can_attack():
		return
	_attack_timer = attack_cooldown
	if roll_to_hit(target):
		target.take_damage(roll_damage())
	else:
		FloatingText.spawn(get_parent(), "Miss", Color(0.85, 0.85, 0.85), target.global_position)


func take_damage(amount: int) -> void:
	if not is_alive:
		return
	current_life = max(0, current_life - amount)
	_flash_on_hit()
	if current_life == 0:
		_die()


func _flash_on_hit() -> void:
	if _flash_tween:
		_flash_tween.kill()
	modulate = Color(1.0, 0.2, 0.2)
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color.WHITE, 0.18)


func _die() -> void:
	is_alive = false

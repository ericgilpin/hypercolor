extends GutTest

var entity: Entity


func before_each() -> void:
	# Set known stats before adding to scene tree so _ready() sees them
	entity = Entity.new()
	entity.stat_strength = 10
	entity.stat_dexterity = 10
	entity.stat_vitality = 10
	entity.stat_energy = 10
	entity.base_damage_min = 5
	entity.base_damage_max = 10
	entity.base_attack_rating = 50
	entity.base_defense = 10
	entity.attack_cooldown = 1.0
	add_child_autofree(entity)
	# _ready() is called by add_child, initializing current_life and current_mana


# --- Computed Properties ---

func test_max_life_scales_with_vitality() -> void:
	entity.stat_vitality = 20
	assert_eq(entity.max_life, 80)  # 20 * 4

func test_max_mana_scales_with_energy() -> void:
	entity.stat_energy = 15
	assert_eq(entity.max_mana, 45)  # 15 * 3

func test_attack_rating_includes_dex_bonus() -> void:
	entity.base_attack_rating = 0
	entity.stat_dexterity = 20
	assert_eq(entity.attack_rating, 100)  # 20 * 5

func test_defense_includes_dex_bonus() -> void:
	entity.base_defense = 0
	entity.stat_dexterity = 20
	assert_eq(entity.defense, 10)  # 20 / 2

func test_damage_max_scales_with_strength_above_10() -> void:
	entity.base_damage_max = 10
	entity.stat_strength = 20
	assert_eq(entity.damage_max, 15)  # 10 + (20 - 10) / 2

func test_damage_max_not_penalized_for_low_strength() -> void:
	entity.base_damage_max = 10
	entity.stat_strength = 5  # below 10, should not reduce max damage
	assert_eq(entity.damage_max, 10)

func test_damage_min_is_always_base_value() -> void:
	entity.stat_strength = 30
	assert_eq(entity.damage_min, entity.base_damage_min)


# --- Hit Chance ---

func test_hit_chance_clamped_to_5_percent_minimum() -> void:
	entity.base_attack_rating = 0
	entity.stat_dexterity = 0
	var target = Entity.new()
	target.base_defense = 9999
	target.stat_dexterity = 0
	add_child_autofree(target)
	assert_eq(entity.calculate_hit_chance(target), 5.0)

func test_hit_chance_clamped_to_95_percent_maximum() -> void:
	entity.base_attack_rating = 9999
	entity.stat_dexterity = 0
	var target = Entity.new()
	target.base_defense = 0
	target.stat_dexterity = 0
	add_child_autofree(target)
	assert_eq(entity.calculate_hit_chance(target), 95.0)

func test_hit_chance_is_50_percent_when_ar_equals_defense() -> void:
	entity.base_attack_rating = 100
	entity.stat_dexterity = 0
	var target = Entity.new()
	target.base_defense = 100
	target.stat_dexterity = 0
	add_child_autofree(target)
	assert_almost_eq(entity.calculate_hit_chance(target), 50.0, 0.01)


# --- Damage and Life State ---

func test_take_damage_reduces_current_life() -> void:
	var starting_life = entity.current_life
	entity.take_damage(10)
	assert_eq(entity.current_life, starting_life - 10)

func test_take_damage_cannot_reduce_life_below_zero() -> void:
	entity.take_damage(99999)
	assert_eq(entity.current_life, 0)

func test_entity_dies_when_life_reaches_zero() -> void:
	entity.take_damage(entity.max_life)
	assert_false(entity.is_alive)

func test_dead_entity_ignores_further_damage() -> void:
	entity.take_damage(entity.max_life)
	assert_false(entity.is_alive)
	entity.current_life = 10  # manually set — should not be changed by another hit
	entity.take_damage(5)
	assert_eq(entity.current_life, 10)

func test_current_life_initialized_to_max_life() -> void:
	assert_eq(entity.current_life, entity.max_life)

func test_current_mana_initialized_to_max_mana() -> void:
	assert_eq(entity.current_mana, entity.max_mana)


# --- Attack Cooldown ---

func test_can_attack_when_timer_is_zero() -> void:
	entity._attack_timer = 0.0
	assert_true(entity.can_attack())

func test_cannot_attack_during_cooldown() -> void:
	entity._attack_timer = 0.5
	assert_false(entity.can_attack())

func test_dead_entity_cannot_attack() -> void:
	entity.is_alive = false
	assert_false(entity.can_attack())

func test_attack_sets_cooldown_timer() -> void:
	var target = Entity.new()
	target.stat_dexterity = 0
	target.base_defense = 0
	add_child_autofree(target)
	entity._attack_timer = 0.0
	entity.attack(target)
	assert_gt(entity._attack_timer, 0.0)

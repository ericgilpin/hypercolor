extends GutTest

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

var enemy: Enemy
var mock_player: Entity


func before_each() -> void:
	enemy = ENEMY_SCENE.instantiate()
	add_child_autofree(enemy)

	mock_player = Entity.new()
	add_child_autofree(mock_player)
	enemy.initialize(mock_player)

	enemy.global_position = Vector2.ZERO
	mock_player.global_position = Vector2(Enemy.AGGRO_RANGE + 100, 0)  # safely outside aggro


# --- Initial State ---

func test_enemy_starts_in_idle() -> void:
	assert_eq(enemy.state, Enemy.State.IDLE)


# --- IDLE -> CHASE ---

func test_idle_transitions_to_chase_when_player_enters_aggro_range() -> void:
	mock_player.global_position = Vector2(Enemy.AGGRO_RANGE - 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.CHASE)

func test_idle_stays_idle_when_player_outside_aggro_range() -> void:
	mock_player.global_position = Vector2(Enemy.AGGRO_RANGE + 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.IDLE)


# --- CHASE -> ATTACK ---

func test_chase_transitions_to_attack_when_player_enters_attack_range() -> void:
	enemy.state = Enemy.State.CHASE
	mock_player.global_position = Vector2(Enemy.ATTACK_RANGE - 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.ATTACK)

func test_chase_stays_in_chase_when_player_between_attack_and_aggro_range() -> void:
	enemy.state = Enemy.State.CHASE
	mock_player.global_position = Vector2(Enemy.ATTACK_RANGE + 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.CHASE)


# --- CHASE -> IDLE (leash) ---

func test_chase_returns_to_idle_when_player_exceeds_leash_range() -> void:
	enemy.state = Enemy.State.CHASE
	mock_player.global_position = Vector2(Enemy.AGGRO_RANGE * 1.5 + 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.IDLE)

func test_chase_stays_in_chase_at_exact_leash_boundary() -> void:
	enemy.state = Enemy.State.CHASE
	mock_player.global_position = Vector2(Enemy.AGGRO_RANGE * 1.5, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.CHASE)


# --- ATTACK -> CHASE ---

func test_attack_returns_to_chase_when_player_moves_out_of_attack_range() -> void:
	enemy.state = Enemy.State.ATTACK
	mock_player.global_position = Vector2(Enemy.ATTACK_RANGE + 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.CHASE)

func test_attack_stays_in_attack_when_player_in_range() -> void:
	enemy.state = Enemy.State.ATTACK
	mock_player.global_position = Vector2(Enemy.ATTACK_RANGE - 1, 0)
	enemy._update_state()
	assert_eq(enemy.state, Enemy.State.ATTACK)

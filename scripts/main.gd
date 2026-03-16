extends Node2D

# Tile source IDs from the TileSet (set in the Godot editor)
const FLOOR_SOURCE_ID = 1
const WALL_SOURCE_ID = 3

# All tiles in our atlas are at position (0,0) since each atlas has one tile
const ATLAS_COORDS = Vector2i(0, 0)

# Dungeon dimensions in tiles
const GRID_WIDTH = 60
const GRID_HEIGHT = 60
const NUM_ROOMS = 12

@onready var tile_map_layer: TileMapLayer = $World/TileMapLayer
@onready var player = $World/Player
@onready var hud: CanvasLayer = $HUDLayer

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

# Player light settings - edit here to change both lights at once
const TORCH_COLOR = Color(1.0, 0.6, 0.27)    # warm orange
const TORCH_ENERGY = 1.2
const TORCH_SCALE = 3.0

const AMBIENT_COLOR = Color(0.29, 0.1, 0.43)  # deep purple
const AMBIENT_ENERGY = 0.4
const AMBIENT_SCALE = 6.0


func _ready() -> void:
	_configure_lights()
	hud.initialize(player)

	var generator = DungeonGenerator.new()
	var grid = generator.generate(GRID_WIDTH, GRID_HEIGHT, NUM_ROOMS)

	_populate_tilemap(grid)
	_place_player(generator.get_first_room_center())
	_spawn_enemies(generator.get_enemy_spawn_points())


func _configure_lights() -> void:
	var torch = player.get_node("TorchLight")
	torch.color = TORCH_COLOR
	torch.energy = TORCH_ENERGY
	torch.texture_scale = TORCH_SCALE

	var glow = player.get_node("AmbientGlow")
	glow.color = AMBIENT_COLOR
	glow.energy = AMBIENT_ENERGY
	glow.texture_scale = AMBIENT_SCALE


func _populate_tilemap(grid: Array) -> void:
	tile_map_layer.clear()

	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var source_id = WALL_SOURCE_ID if grid[y][x] == DungeonGenerator.TILE_WALL else FLOOR_SOURCE_ID
			tile_map_layer.set_cell(Vector2i(x, y), source_id, ATLAS_COORDS)


func _place_player(grid_pos: Vector2i) -> void:
	player.global_position = tile_map_layer.map_to_local(grid_pos)


func _spawn_enemies(spawn_points: Array) -> void:
	for grid_pos in spawn_points:
		var enemy = ENEMY_SCENE.instantiate()
		$World.add_child(enemy)
		enemy.global_position = tile_map_layer.map_to_local(grid_pos)
		enemy.initialize(player)

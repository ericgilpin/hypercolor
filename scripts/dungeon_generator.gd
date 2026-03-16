class_name DungeonGenerator

# Tile type constants used internally by the generator
# These are NOT the Godot source IDs - main.gd handles that mapping
const TILE_WALL = 0
const TILE_FLOOR = 1

var grid: Array = []
var grid_width: int
var grid_height: int
var rooms: Array = []  # Array of Rect2i, one per placed room


func generate(width: int, height: int, num_rooms: int) -> Array:
	grid_width = width
	grid_height = height
	rooms = []

	# Start with a grid full of walls
	grid = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(TILE_WALL)
		grid.append(row)

	# Try to place rooms - some attempts will fail due to overlap, that's fine
	for i in range(num_rooms):
		_try_place_room()

	# Connect each room to the next one with an L-shaped corridor
	for i in range(rooms.size() - 1):
		_connect_rooms(rooms[i], rooms[i + 1])

	return grid


func _try_place_room() -> void:
	var room_w = randi_range(4, 10)
	var room_h = randi_range(4, 8)
	var x = randi_range(1, grid_width - room_w - 1)
	var y = randi_range(1, grid_height - room_h - 1)

	var new_room = Rect2i(x, y, room_w, room_h)

	# Reject if this room overlaps any existing room (with a 1-tile buffer)
	for existing in rooms:
		if new_room.grow(1).intersects(existing):
			return

	# Carve the room out of the wall grid
	for ry in range(y, y + room_h):
		for rx in range(x, x + room_w):
			grid[ry][rx] = TILE_FLOOR

	rooms.append(new_room)


func _connect_rooms(room_a: Rect2i, room_b: Rect2i) -> void:
	# Find the center cell of each room
	var a = Vector2i(
		room_a.position.x + int(room_a.size.x / 2.0),
		room_a.position.y + int(room_a.size.y / 2.0)
	)
	var b = Vector2i(
		room_b.position.x + int(room_b.size.x / 2.0),
		room_b.position.y + int(room_b.size.y / 2.0)
	)

	# Carve an L-shaped path: go horizontal first, then vertical
	_carve_h_corridor(a.x, b.x, a.y)
	_carve_v_corridor(a.y, b.y, b.x)


func _carve_h_corridor(x1: int, x2: int, y: int) -> void:
	for x in range(min(x1, x2), max(x1, x2) + 1):
		for dy in range(-1, 2):  # carve 3 tiles tall (-1, 0, +1)
			var ty = y + dy
			if ty >= 0 and ty < grid_height:
				grid[ty][x] = TILE_FLOOR


func _carve_v_corridor(y1: int, y2: int, x: int) -> void:
	for y in range(min(y1, y2), max(y1, y2) + 1):
		for dx in range(-1, 2):  # carve 3 tiles wide (-1, 0, +1)
			var tx = x + dx
			if tx >= 0 and tx < grid_width:
				grid[y][tx] = TILE_FLOOR


# Returns all room centers except the first (used to spawn enemies)
func get_enemy_spawn_points() -> Array:
	var points: Array = []
	for i in range(1, rooms.size()):
		var room = rooms[i]
		points.append(Vector2i(
			room.position.x + int(room.size.x / 2.0),
			room.position.y + int(room.size.y / 2.0)
		))
	return points


# Returns the center grid cell of the first placed room - used to spawn the player
func get_first_room_center() -> Vector2i:
	if rooms.is_empty():
		return Vector2i(int(grid_width / 2.0), int(grid_height / 2.0))
	var room = rooms[0]
	return Vector2i(
		room.position.x + int(room.size.x / 2.0),
		room.position.y + int(room.size.y / 2.0)
	)

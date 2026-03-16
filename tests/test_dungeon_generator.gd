extends GutTest

var generator: DungeonGenerator

const WIDTH = 40
const HEIGHT = 40
const NUM_ROOMS = 8


func before_each() -> void:
	generator = DungeonGenerator.new()


# --- Grid Structure ---

func test_generate_returns_correct_row_count() -> void:
	var grid = generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	assert_eq(grid.size(), HEIGHT)

func test_generate_returns_correct_column_count() -> void:
	var grid = generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	assert_eq(grid[0].size(), WIDTH)

func test_grid_contains_floor_tiles() -> void:
	var grid = generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	var has_floor = false
	for row in grid:
		for cell in row:
			if cell == DungeonGenerator.TILE_FLOOR:
				has_floor = true
				break
	assert_true(has_floor)

func test_grid_border_is_always_walls() -> void:
	var grid = generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	for x in range(WIDTH):
		assert_eq(grid[0][x], DungeonGenerator.TILE_WALL, "Top row must be wall at x=%d" % x)
		assert_eq(grid[HEIGHT - 1][x], DungeonGenerator.TILE_WALL, "Bottom row must be wall at x=%d" % x)
	for y in range(HEIGHT):
		assert_eq(grid[y][0], DungeonGenerator.TILE_WALL, "Left col must be wall at y=%d" % y)
		assert_eq(grid[y][WIDTH - 1], DungeonGenerator.TILE_WALL, "Right col must be wall at y=%d" % y)


# --- Room Placement ---

func test_generate_places_at_least_one_room() -> void:
	generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	assert_gt(generator.rooms.size(), 0)

func test_rooms_do_not_overlap() -> void:
	generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	for i in range(generator.rooms.size()):
		for j in range(i + 1, generator.rooms.size()):
			var overlaps = generator.rooms[i].intersects(generator.rooms[j])
			assert_false(overlaps, "Rooms %d and %d overlap" % [i, j])

func test_rooms_are_within_grid_bounds() -> void:
	generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	for room in generator.rooms:
		assert_true(room.position.x > 0)
		assert_true(room.position.y > 0)
		assert_true(room.end.x < WIDTH)
		assert_true(room.end.y < HEIGHT)


# --- Spawn Points ---

func test_first_room_center_is_within_grid() -> void:
	generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	var center = generator.get_first_room_center()
	assert_true(center.x >= 0 and center.x < WIDTH)
	assert_true(center.y >= 0 and center.y < HEIGHT)

func test_first_room_center_is_on_a_floor_tile() -> void:
	var grid = generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	var center = generator.get_first_room_center()
	assert_eq(grid[center.y][center.x], DungeonGenerator.TILE_FLOOR)

func test_enemy_spawn_count_is_rooms_minus_one() -> void:
	generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	var spawns = generator.get_enemy_spawn_points()
	assert_eq(spawns.size(), generator.rooms.size() - 1)

func test_enemy_spawns_are_on_floor_tiles() -> void:
	var grid = generator.generate(WIDTH, HEIGHT, NUM_ROOMS)
	for point in generator.get_enemy_spawn_points():
		assert_eq(grid[point.y][point.x], DungeonGenerator.TILE_FLOOR,
			"Enemy spawn at %s is not on a floor tile" % point)

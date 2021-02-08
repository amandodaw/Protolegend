extends Node

onready var tilemap: TileMap = get_parent().get_node("TileMap")
onready var obstacles_positions: PoolVector2Array

onready var astar:= AStar2D.new()

onready var half_cell_size:= Vector2(8,8)

onready var traversable_tiles: PoolVector2Array

onready var used_rect = tilemap.get_used_rect()

func _ready():
	pass


func generate_path(trav_tiles, obstacles):
	traversable_tiles = trav_tiles
	obstacles_positions =  obstacles
	for i in range(traversable_tiles.size()):
		traversable_tiles[i] = tilemap.world_to_map(traversable_tiles[i])
		# Add all tiles to the navigation grid
	_add_traversable_tiles(traversable_tiles)

	# Connects all added tiles
	_connect_traversable_tiles(traversable_tiles)


func on_map_changed(tile: Vector2):
	var tile_array: PoolVector2Array
	obstacles_positions = get_parent().obstacles_positions
	
	tile_array.append(tile)
	_add_traversable_tiles(tile_array)
	_connect_traversable_tiles(tile_array)

## Private functions


# Adds tiles to the A* grid but does not connect them
# ie. They will exist on the grid, but you cannot find a path yet
func _add_traversable_tiles(traversable_tiles):
	# Loop over all tiles
	for tile in traversable_tiles:
		if tile in obstacles_positions:
			continue
		# Determine the ID of the tile
		var id = _get_id_for_point(tile)

		# Add the tile to the AStar navigation
		# NOTE: We use Vector3 as AStar is, internally, 3D. We just don't use Z.(corregido)
		astar.add_point(id, Vector2(tile.x, tile.y))


# Connects all tiles on the A* grid with their surrounding tiles
func _connect_traversable_tiles(traversable_tiles):

	# Loop over all tiles
	for tile in traversable_tiles:

		# Determine the ID of the tile
		var id = _get_id_for_point(tile)

		# Loops used to search around player (range(3) returns 0, 1, and 2)
		for x in range(3):
			for y in range(3):

				# Determines target, converting range variable to -1, 0, and 1
				var adyacent_tile = Vector2(x - 1, y - 1)
				#Quitamos los puntos diagonales
				"""
				if adyacent_tile.length()>1:
					continue
				"""
				var target = tile + adyacent_tile
				# Determines target ID
				var target_id = _get_id_for_point(target)

				# Do not connect if point is same or point does not exist on astar
				if tile == target or not astar.has_point(target_id):
					continue
				#Evitar conexiones diagonales cuando realmente no hay hueco 
				if adyacent_tile.length()>1 and (tile+Vector2.UP in obstacles_positions or tile+Vector2.DOWN in obstacles_positions or tile+Vector2.RIGHT in obstacles_positions or tile+Vector2.LEFT in obstacles_positions):
					continue
				# Connect points
				astar.connect_points(id, target_id, true)
			 


# Determines a unique ID for a given point on the map
func _get_id_for_point(point):

	# Offset position of tile with the bounds of the tilemap
	# This prevents ID's of less than 0, if points are behind (0, 0)
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y

	# Returns the unique ID for the point on the map
	return x + y * used_rect.size.x


## Public functions

# Returns a path from start to end
# These are real positions, not cell coordinates
func get_new_path(start, end):

	# Convert positions to cell coordinates
	var start_tile = tilemap.world_to_map(start)
	var end_tile = tilemap.world_to_map(end)

	# Determines IDs
	var start_id = _get_id_for_point(start_tile)
	var end_id = _get_id_for_point(end_tile)

	# Return null if navigation is impossible
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return null

	# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)

	# Convert Vector3 array (remember, AStar is 3D) to real world points
	var path_world = []
	for point in path_map:
		var point_world = tilemap.map_to_world(Vector2(point.x, point.y)) + half_cell_size
		path_world.append(point_world)
	return path_world

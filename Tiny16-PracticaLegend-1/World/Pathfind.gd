extends Node2D
class_name Pathfind

onready var astar = AStar2D.new()

var obstacles: PoolVector2Array
var tiles: PoolVector2Array
var used_rect: Rect2
var cell_size: Vector2


func generate_navigation(tilemap: TileMap, obstacles_points: PoolVector2Array):
	tiles = tilemap.get_used_cells_by_id(0) + tilemap.get_used_cells_by_id(1)
	obstacles = obstacles_points
	used_rect = tilemap.get_used_rect()
	#tiles = create_point_array()
	add_points()
	connect_points()
	visible = true


func add_points():
	for tile in tiles:
		if tile in obstacles:
			continue
		var id = get_id_for_point(tile)
		astar.add_point(id, tile)


func connect_points():
	for tile in tiles:
		var id = get_id_for_point(tile)
		
		for x in range(3):
			for y in range(3):
				var adyacent_tile = Vector2(x - 1, y - 1)
				
				var target = tile + adyacent_tile
				var target_id = get_id_for_point(target)
				
				if tile == target or not astar.has_point(target_id) or not astar.has_point(id):
					continue
				if adyacent_tile.length()>1 and (tile+Vector2.UP in obstacles or tile+Vector2.DOWN in obstacles or tile+Vector2.RIGHT in obstacles or tile+Vector2.LEFT in obstacles):
					continue
				astar.connect_points(id, target_id)

func get_new_path(start, end, tilemap: TileMap, new_obstacle: Vector2):
	#Check if there is an obstacle

		
	# Convert positions to cell coordinates
	var start_tile = tilemap.world_to_map(start)
	var end_tile = tilemap.world_to_map(end)
	var new_obstacle_tile: Vector2 
	if new_obstacle != Vector2.ZERO:	
		new_obstacle_tile = tilemap.world_to_map(new_obstacle)
	# Determines IDs
	var start_id = get_id_for_point(start_tile)
	var end_id = get_id_for_point(end_tile)
	astar.set_point_disabled(start_id, false)
	var obstacle_id = get_id_for_point(new_obstacle_tile)
	if new_obstacle_tile != Vector2.ZERO:
		obstacle_id = get_id_for_point(new_obstacle_tile)
		astar.set_point_disabled(obstacle_id)
	

	# Return null if navigation is impossible
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return null
	# Otherwise, find the map
	var path_map = astar.get_point_path(start_id, end_id)
	astar.set_point_disabled(end_id)
	# Convert Vector3 array (remember, AStar is 3D) to real world points
	var path_world = []
	for point in path_map:
		var point_world = tilemap.map_to_world(Vector2(point.x, point.y)) + Vector2(8,8)
		path_world.append(point_world)
	return path_world


func get_id_for_point(point: Vector2):
	var x = point.x - used_rect.position.x
	var y = point.y - used_rect.position.y
	
	return x + y * used_rect.size.x

func create_point_array():
	var new_vector_array: PoolVector2Array
	for x in range(80):
		for y in range(45):
			if Vector2(x, y) in obstacles:
				continue
			new_vector_array.append(Vector2(x, y))
	return new_vector_array
	

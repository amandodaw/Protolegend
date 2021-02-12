extends Node2D
class_name Pathfinder

onready var astar = AStar2D.new()

var tilemap: TileMap
var traversable_tiles: PoolVector2Array
var map_size: Vector2
var obstacles: Array


func _ready():
	pass


func generate_navigation(new_tilemap: TileMap, new_obstacles):
	tilemap = new_tilemap
	obstacles = Array(new_obstacles)
	traversable_tiles = tilemap.get_used_cells()
	map_size = tilemap.get_used_rect().size
	add_points()
	connect_points()
	disable_obstacles()


func add_points():
	for tile in traversable_tiles:
		var tile_id = calculate_point_index(tile)
		astar.add_point(tile_id, tile)


func connect_points():
	for tile in traversable_tiles:
		for x in range(3):
			for y in range(3):
				var adyacent_tile = Vector2(x-1, y-1)
				var target = tile + adyacent_tile
				
				
				var tile_id = calculate_point_index(tile)
				var target_id = calculate_point_index(target)
				
				if tile == target or not target_id in astar.get_points():
					continue
				
				astar.connect_points(tile_id, target_id, true)


func connect_point(point):
	for x in range(3):
			for y in range(3):
				var adyacent_tile = Vector2(x-1, y-1)
				var target = point + adyacent_tile
				
				
				var tile_id = calculate_point_index(point)
				var target_id = calculate_point_index(target)
				
				if point == target or not target_id in astar.get_points():
					continue
				
				astar.connect_points(tile_id, target_id, true)


func get_new_path(start, end):
	var start_tile = tilemap.world_to_map(start)
	var end_tile = tilemap.world_to_map(end)
	
	var start_id = calculate_point_index(start_tile)
	var end_id = calculate_point_index(end_tile)
	
	if not astar.has_point(start_id) or not astar.has_point(end_id):
		return null


	var path_map = astar.get_point_path(start_id, end_id)

	var path_world = []
	for point in path_map:
		var point_world = tilemap.map_to_world(Vector2(point.x, point.y)) + tilemap.cell_size/2
		path_world.append(point_world)
	return path_world


func disable_obstacles():
	for obs in obstacles:
		var obs_id = calculate_point_index(obs)

		astar.set_point_disabled(obs_id, true)
		for x in [-1, 1]:
			for y in [-1, 1]:
				var target = obs + Vector2(x,y)
				if target in obstacles:
					print("uyes!")
					var tile1 = target - Vector2(x,0)
					var tile2 = target - Vector2(0,y)
					var tile1_id = calculate_point_index(tile1)
					var tile2_id = calculate_point_index(tile2)
					astar.disconnect_points(tile1_id, tile2_id)


func update_navigation(point, new: bool):
	var point_tile = tilemap.world_to_map(point)
	var point_id = calculate_point_index(point_tile)
	
	if new:
		astar.set_point_disabled(point_id, true)
		obstacles.append(point_tile)
		disable_obstacles()
	else:
		astar.set_point_disabled(point_id, false)
		obstacles.erase(point_tile)
		connect_point(point_tile)


func calculate_point_index(point):
  return point.x + map_size.x * point.y

extends Node2D

onready var tree_scene:= load('res://World/Tree.tscn')
onready var food_scene:= load('res://World/Food.tscn')
onready var herv_scene:= load('res://NPC/Hervivoro.tscn')

onready var line2d: Line2D = $Line2D
onready var tree_spawner:= $TreeSpawner
onready var tilemap: TileMap = $TileMap
onready var pathfinder: Pathfinder = $Pathfinder
onready var player:= $Player

onready var map_size = OS.window_size/tilemap.cell_size/2
onready var half_cell_size  = tilemap.cell_size/tilemap.cell_size * 2

var rng:= RandomNumberGenerator.new()

var herv_number = 10
var tree_number = 20
var food_number = 20
var obstacles_positions: Array


func _input(event):
	if event is InputEventMouseButton:
		var path = pathfinder.get_new_path(player.position, get_global_mouse_position())
		line2d.points = path


func _ready():
	print(map_size)
	rng.randomize()
	generate_border()
	generate_inner()
	spawn_trees()
	spawn_food()
	pathfinder.generate_navigation(tilemap, obstacles_positions)

func generate_border():
	for x in [0, map_size.x]:
		for y in range(map_size.y+1):
			tilemap.set_cell(x, y, 2)
	for y in [0, map_size.y]:
		for x in range(map_size.x):
			tilemap.set_cell(x, y, 2)


func generate_inner():
	for x in range(1, map_size.x):
		for y in range(1, map_size.y):
			tilemap.set_cell(x, y, randi() % 2)


func spawn_trees():
	obstacles_positions.append(Vector2.ZERO)
	for i in tree_number:
		var tree = tree_scene.instance()
		var rand_pos  = Vector2(rng.randi_range(1,map_size.x-1), rng.randi_range(1,map_size.y-1))
		if rand_pos in obstacles_positions:
			continue
		obstacles_positions.append(rand_pos)
		tree.position = tilemap.map_to_world(rand_pos)
		tree_spawner.add_child(tree)


func spawn_food():
	for i in food_number:
		var food = food_scene.instance()
		var rand_pos  = Vector2(rng.randi_range(1,map_size.x-1), rng.randi_range(1,map_size.y-1))
		if rand_pos in obstacles_positions:
			continue
		obstacles_positions.append(rand_pos)
		food.position = tilemap.map_to_world(rand_pos)
		tree_spawner.add_child(food)


func spawn_herv():
	for i in herv_number:
		var herv = herv_scene.instance()
		var rand_pos  = Vector2(rng.randi_range(1,map_size.x-1), rng.randi_range(1,map_size.y-1))
		if rand_pos in obstacles_positions:
			continue
		obstacles_positions.append(rand_pos)
		herv.position = tilemap.map_to_world(rand_pos)
		tree_spawner.add_child(herv)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

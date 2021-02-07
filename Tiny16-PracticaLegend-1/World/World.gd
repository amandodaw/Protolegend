extends Node2D

onready var tree_scene:= load('res://World/Tree.tscn')

onready var tree_spawner:= $TreeSpawner
onready var tilemap: TileMap = $TileMap

onready var map_size = OS.window_size/tilemap.cell_size
onready var half_cell_size  = tilemap.cell_size/tilemap.cell_size * 2

var rng:= RandomNumberGenerator.new()

var tree_number = 400
var tree_positions: PoolVector2Array


func _ready():
	rng.randomize()
	generate_border()
	generate_inner()
	spawn_trees()


func _input(event):
	if event == InputEventMouseButton:
		print(tilemap.world_to_map(event.position))


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
	tree_positions.append(Vector2.ZERO)
	for i in tree_number:
		var tree = tree_scene.instance()
		var rand_pos  = Vector2(rng.randi_range(1,map_size.x-1), rng.randi_range(1,map_size.y-1))
		if rand_pos in tree_positions:
			continue
		tree_positions.append(rand_pos)
		tree.position = tilemap.map_to_world(rand_pos)
		tree_spawner.add_child(tree)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

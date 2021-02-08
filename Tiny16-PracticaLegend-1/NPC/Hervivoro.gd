extends KinematicBody2D


onready var sword_scene: Resource = load('res://Skills/Sword.tscn')

onready var anim: AnimationPlayer = $anim
onready var raycast: RayCast2D = $RayCast2D
onready var pathfind: Pathfind = get_node('../../Pathfind')
onready var tilemap: TileMap = get_node('../../TileMap')

enum state_enum{Idle, Walking, Chopping, Wander}

var state = state_enum.Idle
var speed = 100
var spritedir: String = "Down"
var direction: Vector2
var path: PoolVector2Array

var chop_damage = 100


func _input(event):
	pass


func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			move_along_path()
		state_enum.Chopping:
			pass
		state_enum.Wander:
			wander()


func move_along_path():
	if path == null:
		return
	for i in range(path.size()):
		if path.size() > 1:
			if direction == Vector2.ZERO:
				state = state_enum.Idle
			else:
				state = state_enum.Walking
			anim_dir()
			var distance = path[1] - position
			direction = distance.normalized()
			if distance.length() > 1:
				move_and_slide(direction*speed)
				break
			else:
				path.remove(0)
			if path.size()<=1:
				print("ya esta")
				state = state_enum.Idle


func control():
	direction.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direction.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	anim_dir()
	if direction == Vector2.ZERO:
		state = state_enum.Idle
		return
	
	raycast.cast_to = direction*12
	state = state_enum.Walking
	move_and_slide(direction.normalized()*speed)


func chopping():
	if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "TREE":
		change_state(state_enum.Chopping)
		var sword = sword_scene.instance()
		add_child(sword)
		raycast.get_collider().hp = raycast.get_collider().hp - chop_damage
		print(raycast.get_collider().hp)


func anim_dir():
	match direction:
		Vector2.LEFT:
			spritedir = "Left"
		Vector2.RIGHT:
			spritedir = "Right"
		Vector2.DOWN:
			spritedir = "Down"
		Vector2.UP:
			spritedir = "Up"
	anim.play(str(state_enum.keys()[state],spritedir))


func wander():
	var searching_tile = true
	var target_tile: Vector2
	while searching_tile:
		var target_tiles = get_tile_positions_in_circle(tilemap.world_to_map(global_position), $vision/CollisionShape2D.shape.radius/16)
		target_tile = pick_random_position_v2(tilemap.world_to_map(global_position), $vision/CollisionShape2D.shape.radius/16)
		var obstacles = get_parent().get_parent().obstacles_positions
		if target_tile == tilemap.world_to_map(global_position) or target_tile in obstacles or not target_tile in tilemap.get_used_cells():
			print("vaya")
			continue
		searching_tile = false
	var new_path = pathfind.get_new_path(global_position, tilemap.map_to_world(target_tile), tilemap)
	if new_path == null:
		return
	path = new_path
	state = state_enum.Walking


func get_tile_positions_in_circle(_center_in_tiles, _radius_in_tiles):
	# Get the rectangle bounding the circle
	var radius_vec = Vector2(_radius_in_tiles, _radius_in_tiles)
	var min_pos = (_center_in_tiles - radius_vec).floor()
	var max_pos = (_center_in_tiles + radius_vec).ceil()

	# Convert to integer so we can use range for loop
	var min_x = int(min_pos.x)
	var max_x = int(max_pos.x)
	var min_y = int(min_pos.y)
	var max_y = int(max_pos.y)

	var positions = []

	# Gather all points that are within the radius
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var tile_pos = Vector2(x, y)
			if tile_pos.distance_to(_center_in_tiles) < _radius_in_tiles:
				 positions.append(tile_pos)


func pick_random_position_v2(_center_in_tiles, _radius_in_tiles):
	# Improved trigonometric solution.
	# Density of results will be the same at any distance from center.
	# https://programming.guide/random-point-within-circle.html
	var angle = rand_range(-PI, PI)
	var direction = Vector2(cos(angle), sin(angle))
	var distance = _radius_in_tiles * sqrt(rand_range(0.0, 1.0))
	return (_center_in_tiles + direction * distance).floor()


func change_state(new_state: int):
	state = new_state


func _on_wanderTimer_timeout():
	change_state(state_enum.Wander)

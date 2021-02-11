extends KinematicBody2D


onready var sword_scene: Resource = load('res://Skills/Sword.tscn')

onready var hitbox: Area2D = $hitbox
onready var anim: AnimationPlayer = $anim
onready var raycast: RayCast2D = $RayCast2D
onready var vision: Area2D = $vision
#Cambiar a señales
onready var pathfind: Pathfind = get_node('../../Pathfind')
onready var tilemap: TileMap = get_node('../../TileMap')

enum state_enum{Idle, Walking, Chopping, Wander, Hungry}

var state = state_enum.Idle
var speed = 100
var spritedir: String = "Down"
var direction: Vector2
var path: PoolVector2Array
var target_tile: Vector2

var chop_damage = 100


func _input(event):
	if event.is_action_pressed("accion"):
		change_state(state_enum.Hungry)


func _physics_process(_delta):
	#State machine
	match state:
		state_enum.Idle:
			pass
		state_enum.Walking:
			move_along_path()
		state_enum.Chopping:
			pass
		state_enum.Wander:
			wander()
		state_enum.Hungry:
			get_food_position()


func move_along_path():
	#Move along all points in the path
	#For each point in the path
	for i in range(path.size()):
		
		#If there is more than one point to go
		if path.size() > 1:
			anim_dir()
			#Vector that points to the next point in the path
			var distance = path[1] - position
			direction = distance.normalized()
			#If distance is less than 1 pixel, don't go to the point, and move to the next point in the array
			if distance.length() > 1:
				move_and_slide(direction*speed)
				break
			else:
				path.remove(0)
			if path.size()<=1:
				print("Arrived at last path point")
				state = state_enum.Idle


func control():
	#Get the input from the player
	direction.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direction.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	anim_dir()
	if direction == Vector2.ZERO:
		state = state_enum.Idle
		return
	#Cast a ray to check possible actions
	raycast.cast_to = direction*12
	state = state_enum.Walking
	move_and_slide(direction.normalized()*speed)


func chopping():
	#Func for damaging trees and chop them off
	#If the objective is a tree (Quizas hay que mover este metodo a la futura func de acciones, cuando haya mas de una
	if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "TREE":
		change_state(state_enum.Chopping)
		#Instance a new sword and add it to our node
		var sword = sword_scene.instance()
		add_child(sword)
		#Make damage to the tree
		raycast.get_collider().hp = raycast.get_collider().hp - chop_damage
		print(raycast.get_collider().hp)


func anim_dir():
	#Func for changing the animation that plays
	#Check if the player is moving
	if direction == Vector2.ZERO:
		state = state_enum.Idle
	else:
		state = state_enum.Walking
	match direction:
		Vector2.LEFT:
			spritedir = "Left"
		Vector2.RIGHT:
			spritedir = "Right"
		Vector2.DOWN:
			spritedir = "Down"
		Vector2.UP:
			spritedir = "Up"
	#Call the animation based on the state machine and the direction
	anim.play(str(state_enum.keys()[state],spritedir))


func wander():
	#Choose a random point inside area of vision and set the path and the state to go to it
	var searching_tile = true
	#We have to make shure we choose a valid tile
	while searching_tile:
		#No recuerdo porque cree target_tiles
		var target_tiles = get_tile_positions_in_circle(tilemap.world_to_map(global_position), $vision/CollisionShape2D.shape.radius/16)
		target_tile = pick_random_position_v2(tilemap.world_to_map(global_position), $vision/CollisionShape2D.shape.radius/16)
		var obstacles = get_parent().get_parent().obstacles_positions
		if target_tile == tilemap.world_to_map(global_position) or target_tile in obstacles or not target_tile in tilemap.get_used_cells():
			continue
		searching_tile = false
		
	var new_path = pathfind.get_new_path(global_position, tilemap.map_to_world(target_tile), tilemap, Vector2.ZERO)
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


func get_food_position():
	for body in $vision.get_overlapping_areas():
		if body.get_parent().TYPE == "FOOD":
			var new_path
			# no funciona porque la comida no esta dentro del path al ser un obstaculo. Aqui acaba este proyecto de practica me parece.
			for x in range(3):
				for y in range(3):
					var adyacent_tile = Vector2(x - 1, y - 1)*8
					new_path = get_new_path(body.get_parent().global_position + adyacent_tile)
					if  new_path != []:
						break
					else:
						print("shit  bro")
			path = new_path
			print("si")
			change_state(state_enum.Walking)
			return
	print("No food found")
	change_state(state_enum.Idle)


func _on_wanderTimer_timeout():
	$wanderTimer.wait_time = randi() % 10 + 1
	change_state(state_enum.Wander)


func _on_hitbox_body_entered(body):
		#Rectificar la ruta
		move_and_slide((position - body.position)*16)
		print(body, "recalculando ruta")
		get_new_path(target_tile)


func get_new_path(target):
	if pathfind.get_new_path(global_position, target, tilemap, Vector2.ZERO) == null:
		return []
	else:
		target_tile = target
		return pathfind.get_new_path(global_position, target, tilemap, Vector2.ZERO)
	

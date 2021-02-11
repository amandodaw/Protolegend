extends KinematicBody2D

onready var sword_scene: Resource = load('res://Skills/Sword.tscn')

onready var tilemap: TileMap = get_node('../TileMap')

onready var anim: AnimationPlayer = $anim
onready var raycast: RayCast2D = $RayCast2D
var new_item: Node
var holding: Node
var holding_sprite: Sprite

enum state_enum{Idle, Walking, Chopping, Grabbing}

var state = state_enum.Idle
var speed = 100
var spritedir: String = "Down"
var direction: Vector2

var chop_damage = 100

var is_grabbing = false


func _input(event):
	if event.is_action_pressed("accion"):
		if is_grabbing:
			drop_item()
			return
		if !raycast.is_colliding() or raycast.get_collider() is TileMap :
			return
		print(state_enum.keys()[state])
		if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "TREE" or raycast.get_collider().TYPE == "FOOD" and state != state_enum.Chopping:
			change_state(state_enum.Chopping)
			anim_dir()
			chopping()
		elif raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "ITEM":
			grabbing()



func _physics_process(_delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			control()
		state_enum.Chopping:
			pass
		state_enum.Grabbing:
			pass
		


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
	if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "TREE" or raycast.get_collider().TYPE == "FOOD":
		var sword = sword_scene.instance()
		add_child(sword)
		raycast.get_collider().hp = raycast.get_collider().hp - chop_damage
		print(raycast.get_collider().hp)


func grabbing():
	if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "ITEM":
		holding = raycast.get_collider()
		change_state(state_enum.Grabbing)
		holding_sprite = holding.get_node('Sprite').duplicate()
		new_item = holding.duplicate()
		holding.queue_free()
		add_child(holding_sprite)
		change_state(state_enum.Idle)
		is_grabbing = true


func drop_item():
	remove_child(holding_sprite)
	match spritedir:
		"Left":
			var new_pos = tilemap.world_to_map(position) + Vector2.LEFT
			new_item.global_position = tilemap.map_to_world(new_pos)
		"Right":
			var new_pos = tilemap.world_to_map(position) + Vector2.RIGHT
			new_item.global_position = tilemap.map_to_world(new_pos)
		"Up":
			var new_pos = tilemap.world_to_map(position) + Vector2.UP
			new_item.global_position = tilemap.map_to_world(new_pos)
		"Down":
			var new_pos = tilemap.world_to_map(position) + Vector2.DOWN
			new_item.global_position = tilemap.map_to_world(new_pos)
	get_parent().get_node("TreeSpawner").add_child(new_item)
	is_grabbing = false


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


func change_state(new_state: int):
	print("nuevo estado: ", state_enum.keys()[new_state])
	state = new_state

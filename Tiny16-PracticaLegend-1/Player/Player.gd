extends KinematicBody2D

onready var sword_scene: Resource = load('res://Skills/Sword.tscn')

onready var tilemap: TileMap = get_node('../TileMap')
onready var pathfinder: Pathfinder = get_node('../Pathfinder')

signal update_navigation

#A ver, están ordenadas. Esto son nodos:
onready var anim: AnimationPlayer = $anim
onready var raycast: RayCast2D = $RayCast2D
var new_item: Node
var holding: Node
var holding_sprite: Sprite

enum state_enum{Idle, Walking, Chopping, Grabbing}

var state = state_enum.Idle
var speed = 100
var chop_damage = 100
var hunger = 100
var spritedir: String = "Down"
var direction: Vector2


var is_grabbing = false setget set_is_grabbing


func _input(event):
	if event.is_action_pressed("accion"):
		raycast.force_raycast_update()
		var collider = raycast.get_collider()
		if is_grabbing:
			drop_item()
			return
		if !raycast.is_colliding() or collider is TileMap :
			return
		if collider is StaticBody2D and (collider.TYPE == "TREE" or "FOOD") and state != state_enum.Chopping and not collider.TYPE == "ITEM":
			print((collider.TYPE == "TREE" || "FOOD"))
			print(collider.TYPE)
			anim_dir()
			chopping()
		elif collider is StaticBody2D and collider.TYPE == "ITEM":
			grabbing()
	if event.is_action_pressed("usar"):
		if is_grabbing:
			if new_item.TYPE == "ITEM" and new_item.SUBTYPE == "FOOD":
				remove_child(holding_sprite)
				set_is_grabbing(false)
				hunger += 50


func _ready():
	connect("update_navigation", pathfinder, "update_navigation")


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
	change_state(state_enum.Chopping)
	if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "TREE" or raycast.get_collider().TYPE == "FOOD":
		var sword = sword_scene.instance()
		add_child(sword)
		raycast.get_collider().hp = raycast.get_collider().hp - chop_damage
		print(raycast.get_collider().hp)


func grabbing():
	if raycast.get_collider() is StaticBody2D and raycast.get_collider().TYPE == "ITEM":
		holding = raycast.get_collider()
		holding_sprite = holding.get_node('Sprite').duplicate()
		new_item = holding.duplicate()
		holding.queue_free()
		add_child(holding_sprite)
		set_is_grabbing(true)


func drop_item():
	var new_pos = tilemap.world_to_map(position)
	match spritedir:
		"Left":
			new_pos += Vector2.LEFT
		"Right":
			new_pos += Vector2.RIGHT
		"Up":
			new_pos += Vector2.UP
		"Down":
			new_pos += Vector2.DOWN
	if new_pos in get_parent().obstacles_positions:
		print("NO SE PUEDE DEJAR AHI")
		return
	remove_child(holding_sprite)
	new_item.global_position = tilemap.map_to_world(new_pos)
	get_parent().get_node("TreeSpawner").add_child(new_item)
	emit_signal("update_navigation", new_pos, true)
	set_is_grabbing(false)


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


func set_is_grabbing(value: bool):
	is_grabbing = value
	if is_grabbing:
		speed = speed/2
	else:
		speed = speed*2


func _on_hungerTimer_timeout():
	hunger -= 1
	$Label.text = "Hunger: " + str(hunger)

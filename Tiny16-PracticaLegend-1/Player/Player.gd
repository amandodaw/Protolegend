extends KinematicBody2D

onready var sword_scene: Resource = load('res://Skills/Sword.tscn')

onready var anim: AnimationPlayer = $anim
onready var raycast: RayCast2D = $RayCast2D

enum state_enum{Idle, Walking, Chopping}

var state = state_enum.Idle
var speed = 100
var spritedir: String
var direction: Vector2

var chop_damage = 100


func _input(event):
	if event.is_action_pressed("accion"):
		if state == state_enum.Chopping:
			return
		if raycast.is_colliding():
			state = state_enum.Idle
			anim_dir()
			chopping()



func _physics_process(delta):
	match state:
		state_enum.Idle, state_enum.Walking:
			control()
		state_enum.Chopping:
			pass
		


func control():
	direction.x = Input.get_action_strength("derecha") - Input.get_action_strength("izquierda")
	direction.y = Input.get_action_strength("abajo") - Input.get_action_strength("arriba")
	
	anim_dir()
	if direction == Vector2.ZERO:
		state = state_enum.Idle
		return
	
	raycast.cast_to = direction*8
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


func change_state(new_state: int):
	state = new_state

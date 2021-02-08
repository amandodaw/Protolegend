extends Camera2D

onready var player: KinematicBody2D = get_node('../Player')
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 400

func _process(_delta):
	follow_player()
	#control(delta)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func control(delta):
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	position += direction.normalized() * speed  * delta


func follow_player():
	position = player.position

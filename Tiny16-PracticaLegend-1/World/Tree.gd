extends StaticBody2D

onready var wood_scene:= load('res://World/Wood.tscn')

var hp = 400 setget attacked
const TYPE: String = "TREE"
signal map_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("map_changed", get_node('../../Pathfinding'),"on_map_changed")
	pass # Replace with function body.

func attacked(value):
	hp = value
	if hp <= 0:
		var wood = wood_scene.instance()
		wood.position = global_position
		get_parent().add_child(wood)
		queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

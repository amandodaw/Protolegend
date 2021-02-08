extends StaticBody2D


var hp = 400 setget attacked
const TYPE: String = "FOOD"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func attacked(value):
	hp = value
	if hp <= 0:
		queue_free()

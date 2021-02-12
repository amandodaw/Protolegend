extends 'res://World/object.gd'

onready var food_harvested_scene = load('res://World/Food_haversted.tscn')

onready var tilemap: TileMap = get_node('../../TileMap')

var hp = 100 setget attacked
var TYPE: String = "FOOD"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("si si")
	pass  # Replace with function body.


func attacked(value):
	hp = value
	if hp <= 0:
		var food_item = food_harvested_scene.instance()
		food_item.position = position + Vector2(2, 4)
		get_parent().add_child(food_item)
		queue_free()

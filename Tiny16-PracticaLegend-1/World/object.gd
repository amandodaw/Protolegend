extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal update_navigation

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("update_navigation", get_node('../../Pathfinder'), "update_navigation")
	connect("tree_exiting", self, "refresh_map")
	pass # Replace with function body.


func refresh_map():
	emit_signal("update_navigation", global_position, false)

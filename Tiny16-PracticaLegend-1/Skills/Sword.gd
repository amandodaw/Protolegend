extends Sprite


onready var player:= get_parent()
var half_cell_size:= 8
signal finished


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("finished",get_parent(),"change_state")
	match player.spritedir:
		"Left":
			position = Vector2.LEFT*half_cell_size
			$anim.play("usingLeft")
		"Right":
			position = Vector2.RIGHT*half_cell_size
			$anim.play("usingRight")
		"Down":
			position = Vector2.DOWN*half_cell_size
			flip_h = true
			$anim.play("usingLeft")
		"Up":
			position = Vector2.UP*half_cell_size
			$anim.play("usingRight")




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_anim_animation_finished(anim_name):
	emit_signal("finished", player.state_enum.Idle)
	queue_free()

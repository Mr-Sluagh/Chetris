extends TextureButton
signal play
signal pause

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Play_touched():
	
	pressed = true

func _on_PlayPause_toggled(button_pressed):
	
	if button_pressed:
		
		emit_signal("play")
		
	else:
		
		emit_signal("pause")

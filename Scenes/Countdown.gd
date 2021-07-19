extends Label
signal done

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _exit_tree():
	
	get_tree().paused = false

func _on_Timer_timeout():
	
	if $Timer.count <= 0:
		
		get_tree().paused = false
		emit_signal("done")
		queue_free()
	
	text = str($Timer.count - 1)

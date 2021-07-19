extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var count = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	
	count -= 1
		

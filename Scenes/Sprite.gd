extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
		
func init(id):
	
	#var file = "res://Resources/res/"
	var key = Vector3(0,0,0)
	
	if id.to_upper() == id:
		#file += "w_" + id.to_lower()
		pass
	else:
		key = Vector3(1,1,1)
		#file += "b_" + id	
	#file += ".png"
	
	#var image = load(file)
	#texture = image
	play(id)
	material = material.duplicate()
	material.set_shader_param("key", key)
	material.set_shader_param("val", Vector3(0.5,0.5,0.5))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

onready var tween = $Tween
func _on_Piece_game_over():

	play("explode")

extends Node2D

signal landed(id, score)
signal game_over

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Board_landed(id, score):
	
	emit_signal("landed", id, score)

func _on_Board_game_over():
	
	emit_signal("game_over")

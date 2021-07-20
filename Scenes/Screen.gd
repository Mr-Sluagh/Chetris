extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func black_count():
	
	var board = find_node("Board")
	return board.black_count

func white_count():
	
	var board = find_node("Board")
	return board.white_count

func is_king_exposed():
	
	var board = find_node("Board")
	return board.is_king_exposed()

func _on_PlayPause_play():
	var view = find_node("Viewport")
	view.play()


func _on_PlayPause_pause():
	var view = find_node("Viewport")
	view.pause()

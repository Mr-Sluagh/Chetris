extends Node2D


signal game_over
signal resume


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

func play():
	var view = find_node("Viewport")
	view.play()


func pause():
	var view = find_node("Viewport")
	view.pause()

func _on_Board_game_over():
	emit_signal("game_over")


func _on_Viewport_resume():
	emit_signal("resume")

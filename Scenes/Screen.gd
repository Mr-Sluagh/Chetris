extends Node2D


signal game_over
signal resume
signal show_title(title)
signal landed(id, score)
signal show_board


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func header_say(text):
	
	$ViewportContainer/Viewport/Header.text = text

func footer_say(text):
	
	$ViewportContainer/Viewport/Footer.text = text
	
func show_board():
	
	emit_signal("show_board")

func show_title(title = ""):
	
	emit_signal("show_title", title)

func clear():
	
	$ViewportContainer.clear()

func black_count():
	
	var board = find_node("Board")
	return board.black_count

func white_count():
	
	var board = find_node("Board")
	return board.white_count

func is_king_exposed():
	
	var board = find_node("Board")
	return board.is_king_exposed()

func wait():
	var view = find_node("Viewport")
	view.wait()

func play():
	var view = find_node("Viewport")
	view.play()
	
func pause():
	var view = find_node("Viewport")
	view.pause()
	
func end_game():
	
	$ViewportContainer/Viewport.end_game()

func _on_Board_game_over():
	emit_signal("game_over")

func _on_Viewport_resume():
	emit_signal("resume")


func draft(id, column):
	
	$ViewportContainer/Viewport/Board.draft(id, column)

func _on_Board_landed(id, score):
	
	emit_signal("landed", id, score)

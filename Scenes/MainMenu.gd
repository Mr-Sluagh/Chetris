extends Node2D

signal play_touched

var DEFAULT_WIDTH = 320
var DEFAULT_HEIGHT = 480

var Board = load("res://Scenes/Board.tscn")

func _ready():
		
	var PlayPause = get_tree().get_root().find_node("PlayPause",true,false)
	self.connect("play_touched", PlayPause, "_on_Play_touched")
	PlayPause.connect("play", self, "_on_Play_pressed")

func _exit_tree():
	
	var PlayPause = get_tree().get_root().find_node("PlayPause",true,false)
	PlayPause.disconnect("play", self, "_on_Play_pressed")

func _on_Play_pressed():
	
	emit_signal("play_touched")
	var parent = get_parent()
	if not parent.find_node("Board", true, false):
		var game = Board.instance()
		var view_rect = get_viewport_rect()
		game.position = Vector2(view_rect.size.x * 0.5, view_rect.size.y * 0.5)
		parent.add_child(game)
	queue_free()

func _on_Quit_pressed():
	get_tree().quit()

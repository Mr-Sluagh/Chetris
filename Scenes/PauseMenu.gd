extends Node2D
signal play

onready var MainMenu = load("res://Scenes/MainMenu.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var PlayPause = get_tree().get_root().find_node("PlayPause",true,false)
	self.connect("play", PlayPause, "_on_Play_touched")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _exit_tree():
	
	var PlayPause = get_tree().get_root().find_node("PlayPause",true,false)
	self.disconnect("play", PlayPause, "_on_Play_touched")

func _on_Resume_pressed():
	emit_signal("play")


func _on_Main_Menu_pressed():

	var board = get_parent()
	var screen = board.get_parent()
	var mainMenu = MainMenu.instance()
	var view_rect = get_viewport_rect()
	mainMenu.position = Vector2(view_rect.size.x * 0.5, view_rect.size.y * 0.5)
	screen.add_child(mainMenu)
	board.queue_free()

extends Viewport

signal resume

var count = -1
onready var timer := get_tree().create_timer(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$OnScreen/Background.visible = true
	$OnScreen/Board.visible = false
	$OnScreen/Title.visible = false
	$OnScreen/Board.clear()

func _init():
	
	count = -1

func clear():
	
	_init()
	_ready()

func pause():

	count = -1
	timer.time_left = 0
	
	$OnScreen/Title.text = "Paused"
	$OnScreen/Title.visible = true
	$OnScreen/Board.pause()

func play():
	
	$OnScreen/Title.visible = false
	$OnScreen/Board.play()

func wait():

	count = 3
	
	while count > 0:
		
		$OnScreen/Title.text = str(count)
		timer = get_tree().create_timer(1)
		yield(timer, "timeout")
		count -= 1

	if count < 0:
		
		return
		
	emit_signal("resume")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func end_game():
	
	$OnScreen/Title.text = "Game\nOver"
	$OnScreen/Title.visible = true
	$OnScreen/Board.end_game()

func _on_Screen_show_title(title):
	
	$OnScreen/Title.text = title
	$OnScreen/Title.visible = true

func _on_Screen_show_board():
	$OnScreen/Board.visible = true

extends Viewport

signal resume

var count = -1
onready var timer := get_tree().create_timer(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Background.visible = true
	$Board.visible = false
	$Title.visible = false
	$Board.clear()

func _init():
	
	count = -1

func clear():
	
	_init()
	_ready()

func pause():

	count = -1
	timer.time_left = 0
	
	$Title.text = "Paused"
	$Title.visible = true
	$Board.pause()

func play():
	
	$Title.visible = false
	$Board.play()

func wait():

	count = 3
	
	while count > 0:
		
		$Title.text = str(count)
		timer = get_tree().create_timer(1)
		yield(timer, "timeout")
		count -= 1

	if count < 0:
		
		return
		
	emit_signal("resume")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Board_game_over():
	
	$Title.text = "Game\nOver"
	$Title.visible = true

func _on_Screen_show_title(title):
	
	$Title.text = title
	$Title.visible = true

func _on_Screen_show_board():
	$Board.visible = true

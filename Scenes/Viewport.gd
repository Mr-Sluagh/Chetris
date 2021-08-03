extends Viewport

signal resume

var count = -1
onready var timer := get_tree().create_timer(0)


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func pause():

	count = -1
	timer.time_left = 0
	
	$Title.text = "Paused"
	$Title.visible = true
	$Board.pause()

func play():
	
	print("board play pressed")

	count = 3
	
	while count > 0:
		
		$Title.text = str(count)
		timer = get_tree().create_timer(1)
		yield(timer, "timeout")
		count -= 1

	if count < 0:
		
		return

	$Title.visible = false
	$Board.play()
	emit_signal("resume")
"""
func _on_Countdown_done():
	
	emit_signal("resume")
	$Board.play()
"""		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Board_game_over():
	
	$Title.text = "Game\nOver"
	$Title.visible = true

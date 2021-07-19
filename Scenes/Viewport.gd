extends Viewport


var Countdown = load("res://Scenes/Countdown.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

func pause():
	
	var countdown = get_node("Countdown")
	
	if countdown:
		
		countdown.queue_free()
		
	$Title.text = "Paused"
	$Title.visible = true
	
	$Board.pause()

func play():
	
	print("board play pressed")

	var count = 3
	
	while count:
		
		$Title.text = str(count)
		yield(get_tree().create_timer(1), "timeout")
		count -= 1

	$Title.visible = false
	$Board.play()

func _on_Countdown_done():
	
	$Board.play()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Board_game_over():
	
	$Title.text = "Game\nOver"
	$Title.visible = true

extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_score := 0
var current_level := 0
var current_combo := 0
var last_score := 0
var current_second := 0.0
var cursor := 0
var inc := -1
var turn = 0
var draft_delay = INF
var state_time = 0.0
var permissive = false
var title_time = 5.0
var begin = false
export var record := false

enum State {TITLE, DEMO, PLAY, PAUSE, WAIT, OVER}
var state = State.TITLE

onready var nexts = [
	$NextWhiteRook,
	$NextBlackKnight,
	$NextWhiteBishop,
	$NextBlackQueen,
	$NextWhiteQueen,
	$NextBlackBishop,
	$NextWhiteKnight,
	$NextBlackRook
	]

var next = 'P'

func clock_on():
	
	match state:
		
		State.TITLE:
			
			return false
			
		State.DEMO:
			
			return true
			
		State.PLAY:
			
			return true
			
		State.PAUSE:
			
			return false
			
		State.OVER:
			
			return false

func _init():
	
	state_time = 0.0
	current_score = 0
	current_level = 0
	current_combo = 0
	last_score = 0
	current_second = 0.0
	begin = false
	cursor = 0
	inc = -1
	
func to_title():
	
	_init()
	_ready()
	next_off()
	$Demo.stop_recording()
	$Screen.clear()
	$Screen.show_board()
	$Screen.show_title("Chetris")
	return true

func run_game():
	
	print("Main.run_game()")
	$Screen.play()

func to_play():
	
	if state != State.WAIT:
		
		return false
		
	run_game()
	
	if begin:
		
		if record:
		
			$Demo.start_recording()
		
	elif record:
		
		$Demo.set_process(true)
		
	return true

func to_demo():
	
	var next :bool= false
	
	if state == State.DEMO:
		
		next = true
		
	elif state != State.TITLE:
		
		return false
	
	$Screen.clear()
	$Screen.show_board()
	
	if $Demo.play_sequence(next):
		
		run_game()
	
	return true

func to_pause():
	
	if state != State.PLAY and state != State.WAIT:
		
		return false
	
	if record:
		
		$Demo.set_process(false)
	
	$Screen.pause()
	
	return true
	
func to_wait():
	
	$Screen.wait()
	return true
	
func to_over():
	
	if state != State.PLAY:
		
		return false
	
	$Demo.stop_recording()
	
	$PlayPause.disabled = true
	$PlayPause.pressed = false
	$PlayPause.disabled = false
	$Screen.end_game()
	
	return true

func change_state(to):
	
	var last = state
	var success :bool= false
	
	match to:
		
		State.TITLE:
			
			success = to_title()
		
		State.DEMO:
			
			success = to_demo()
		
		State.PLAY:
			
			success = to_play()
		
		State.PAUSE:
			
			success = to_pause()
			
		State.WAIT:
			
			success = to_wait()
			
		State.OVER:
			
			success = to_over()
	
	if success:
		
		if state == last:
	
			state = to
			state_time = 0.0
		
	else:
		
		print("Main: failed to change state from " + str(state) + " to " + str(to))
		assert(permissive)

func next_demo():
	
	change_state(State.DEMO)

func next_off():
	
	for next in nexts:
		
		next.off()

# Called when the node enters the scene tree for the first time.
func _ready():

	SilentWolf.configure({
		"api_key": "0JoEX0Qbj55jyxZLWqtylaVkYDuPPaRm4QtIk8DH",
		"game_id": "Chetris",
		"game_version": "0.1",
		"log_level": 1
	})
	
	SilentWolf.configure_scores({
		"open_scene_on_close": "res://scenes/Main.tscn"
	})

	$Screen.position.x = 0
	$Screen.clear()
	$Screen.show_board()
	$Screen.show_title("Chetris")
	$Level.init("Level", 0)
	$Combo.init("Combo", 0)
	$Combo.set_value(0)
	$Score.set_score(0)
	$Time.set_time(0)
	$PlayPause.disabled = true
	$PlayPause.pressed = false
	$PlayPause.disabled = false

func landed(id, score):
	
	var black_count = $Screen.black_count()
	var white_count = $Screen.white_count()
	var n = nexts[cursor]
	
	turn += 1
	update_meters(score)
	draft_delay = speed()
	
	if last_score:
		
		if $Screen.is_king_exposed():
			
			print("Main.draft(): king exposed")
			
			var parity = 0
			next = 'K'
			
			if not black_count:
				
				parity = 1
				next = 'k'
				
			for i in range(len(nexts)):
				
				if i % 2 == parity:
					
					nexts[i].bad_on()
			
		else:
			
			print("Main.draft(): no king exposed")
			
			n.good_on()
			next = n.id
		
	else:
		
		n.bad_on()

		if cursor % 2:
		
			next = 'p'

		else:
			
			next = 'P'
		
func draft():
	print("Main.draft(): next = " + next)
	next_off()
	$Screen.draft(next, cursor)
	
	var black_count = $Screen.black_count()
	var white_count = $Screen.white_count()
	
	if turn % 2:
		
		inc = -1
		cursor = len(nexts) - 1
		
	else:
		
		inc = 1
		cursor = 0
	
	cursor += current_combo * inc
	wrap_cursor()
	
	nexts[cursor].may_on()

func wrap_cursor():
	
	while cursor >= len(nexts):
		
		cursor -= len(nexts)
		
	while cursor < 0:
		
		cursor += len(nexts)

func _on_Piece_moved():
	
	for next in nexts:
		
		next.off()
	
	cursor += inc
	wrap_cursor()
	var next = nexts[cursor]
	next.may_on()
	
func _on_Piece_start_game():
	
	print("Main._on_Piece_start_game()")
	var black_count = $Screen.black_count()
	var white_count = $Screen.white_count()
	
	if turn % 2:
		
		inc = -1
		
	else:
		
		inc = 1
	
	if inc > 0:
		
		cursor = 0
		
	elif inc < 0:
		
		cursor = len(nexts) - 1
	
	cursor += current_combo * inc
	wrap_cursor()

	nexts[cursor].may_on()
	
func speed():
	
	return 1.0 - current_level / 1000

func update_meters(score):
	
	if score:
		
		current_combo += 1
		current_level += 1
		
	else:
		
		current_combo = 0
	
	current_score += score
	
	$Score.set_score(current_score)
	$Combo.set_value(current_combo)
	$Level.set_value(current_level)
	
	last_score = score
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	match state:
	
		State.TITLE:
			
			if state_time >= title_time or Input.is_action_just_pressed("input_tap"):
			
				begin = true
				change_state(State.DEMO)
		
		State.DEMO, State.PLAY:
				
			if begin:
				
				print("Main: drafting")
				draft()
				begin = false
			
			current_second += delta
			
			if current_second >= 1.0:
				
				print(state)
				$Time.set_time(int(state_time))
				current_second -= 1.0
				
			if draft_delay != INF:
				
				if draft_delay > 0.0:
				
					draft_delay -= delta
				
				else:
					
					draft()
					draft_delay = INF
		
		State.PAUSE:
			
			pass
			
		State.WAIT:
			
			pass
			
		State.OVER:
			
			pass
	
	if state == State.TITLE:
		
		pass
	
	state_time += delta

func _on_PlayPause_pause():
	
	change_state(State.PAUSE)

func _on_Screen_game_over():
	
	change_state(State.OVER)

func _on_Screen_resume():
	
	change_state(State.PLAY)

func _on_Off_pressed():
	
	get_tree().quit()


func _on_Reset_pressed():
	
	change_state(State.TITLE)


func _on_PlayPause_play():
	
	match state:
		
		State.TITLE:
			
			begin = true
			change_state(State.WAIT)
		
		State.DEMO:
			
			begin = true
			change_state(State.WAIT)
		
		State.PLAY:
			
			assert(permissive)
		
		State.PAUSE:
			
			change_state(State.WAIT)
			
		State.WAIT:
			
			assert(permissive)
			
		State.OVER:
			
			change_state(State.TITLE)

func _on_Screen_landed(id, score):
	
	landed(id, score)


func _on_Demo_done():
	
	change_state(State.TITLE)

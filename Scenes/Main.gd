extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_time := 0.0
var current_score := 0
var current_level := 0
var current_combo := 0
var last_score := 0
var clock_on := false
var current_second := 0.0
var cursor := 0
var inc := -1
var turn = 0
var draft_delay = INF

enum State {TITLE, PLAY, PAUSE, WAIT, OVER}
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

func _init():
	
	current_time = 0.0
	current_score = 0
	current_level = 0
	current_combo = 0
	last_score = 0
	clock_on = false
	current_second = 0.0
	cursor = 0
	inc = -1
	
func to_title():
	
	_init()
	_ready()
	next_off()
		
func to_play():
	
	assert(state == State.WAIT)
	clock_on = true
	$Screen.play()
	
	if current_time == 0.0:
		
		draft()
	
func to_pause():
	
	assert(state == State.PLAY or state == State.WAIT)
	
	clock_on = false
	$Screen.pause()
	
func to_wait():
	
	$Screen.wait()
	
func to_over():
	
	assert(state == State.PLAY)
	clock_on = false
	$PlayPause.disabled = true
	$PlayPause.pressed = false
	$PlayPause.disabled = false
	$Screen.end_game()

func change_state(to):
	
	match to:
		
		State.TITLE:
			
			to_title()
			
		State.PLAY:
			
			to_play()
			
		State.PAUSE:
			
			to_pause()
			
		State.WAIT:
			
			to_wait()
			
		State.OVER:
			
			to_over()
	
	state = to

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
	var ret = 'P'
	var next = nexts[cursor]
	
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
				
			for n in range(len(nexts)):
				
				if n % 2 == parity:
					
					nexts[n].bad_on()
			
		else:
			
			print("Main.draft(): no king exposed")
			
			next.good_on()
			next = next.id
		
	else:
		
		next.bad_on()

		if cursor % 2:
		
			next = 'p'

func draft():
	
	next_off()
	$Screen.draft(next, cursor)
	
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
	
	clock_on = true
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

	if clock_on:

		current_second += delta
		current_time += delta
		
		if current_second >= 1.0:
			
			$Time.set_time(int(current_time))
			current_second -= 1.0
			
		if draft_delay != INF:
			
			if draft_delay > 0.0:
			
				draft_delay -= delta
			
			else:
				
				draft()
				draft_delay = INF
			

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
	
	if state == State.OVER:
		
		change_state(State.TITLE)
	
	else:
	
		change_state(State.WAIT)


func _on_Screen_landed(id, score):
	
	landed(id, score)

extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var current_time := 0.0
export var current_score := 0
export var current_level := 0
export var current_combo := 0
export var last_score := 0
export var clock_on := false
var current_second := 0.0
export var cursor := 0
export var inc := -1

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
	$Level.init("Level", 0)
	$Combo.init("Combo", 0)
	$Combo.set_value(0)
	$Score.set_score(0)
	$Time.set_time(0)

func draft():
	
	var black_count = $Screen.black_count()
	var white_count = $Screen.white_count()
	var ret = 'P'
	var next = nexts[cursor]
	
	if last_score:
		
		if $Screen.is_king_exposed():
			
			print("Main.draft(): king exposed")
			
			var parity = 0
			ret = 'K'
			
			if not black_count:
				
				parity = 1
				ret = 'k'
				
			for n in range(len(nexts)):
				
				if n % 2 == parity:
					
					nexts[n].bad_on()
			
		else:
			
			print("Main.draft(): no king exposed")
			
			next.good_on()
			ret = next.id
		
	else:
		
		next.bad_on()

		if cursor % 2:
		
			ret = 'p'
		
	return ret
	
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
	
	if black_count > white_count:
		
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
	
func _on_Piece_captured(score):
	
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

func _on_Piece_game_over():
	
	clock_on = false
	SilentWolf.Scores.persist_score("test", current_score) 
	get_tree().change_scene("res://Plugins/silent_wolf/Scores/Leaderboard.tscn")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if clock_on:

		current_second += delta
		current_time += delta
		
		if current_second >= 1.0:
			
			$Time.set_time(int(current_time))
			current_second -= 1.0

func _on_PlayPause_pause():
	
	clock_on = false

func _on_Sc_play():
	
	clock_on = true

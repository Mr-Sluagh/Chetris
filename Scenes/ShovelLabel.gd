extends Label


export var wait := 1
var alternate := false

# Called when the node enters the scene tree for the first time.
func _ready():
	while true:
		if alternate:
			var font = BitmapFont.new()
			font.create_from_fnt("res://Resources/fonts/shovelcore_Wb.fnt")
			self.set("custom_fonts/font", font)
		else:
			var font = BitmapFont.new()
			font.create_from_fnt("res://Resources/fonts/shovelcore_Bw.fnt")
			self.set("custom_fonts/font", font)
		alternate = not alternate
		yield(get_tree().create_timer(wait), "timeout")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

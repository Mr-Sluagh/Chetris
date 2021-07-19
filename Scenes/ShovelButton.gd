extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_hovered():
		var font = BitmapFont.new()
		font.create_from_fnt("res://Resources/fonts/shovelcore_Wb.fnt")
		self.set("custom_fonts/font", font)
	else:
		var font = BitmapFont.new()
		font.create_from_fnt("res://Resources/fonts/shovelcore_Bw.fnt")
		self.set("custom_fonts/font", font)

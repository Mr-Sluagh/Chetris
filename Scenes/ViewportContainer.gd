extends ViewportContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var vis = get_viewport_rect()
	var view = get_rect()
	view.position.x = (vis.size.x - view.size.x) * 0.5
	view.position.y = vis.size.y * 0.0
	set_position(view.position)

func clear():
	
	$Viewport.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

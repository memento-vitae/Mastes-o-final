extends Node2D
func _ready():
	$".".visible=false
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if(get_tree().paused==false):
			get_tree().paused=true
			$".".visible=true
		else:
			$".".visible=false
			get_tree().paused=false


extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.percent_visible=0
func _process(delta):
	if($Label.percent_visible<1):
		$Label.percent_visible+=0.5*delta


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_play_pressed():
	var file=File.new()
	var localsave="save/savefase.save"
	var fase
	if(file.file_exists(localsave)):
		file.open(localsave,File.READ)
		fase=file.get_as_text()
		file.close()
	else:
		fase="res://Fases/fase1.tscn"
		file.open(localsave,File.WRITE)
		file.store_string(fase)
		file.close()
	get_tree().change_scene(fase)


func _on_and_pressed():
	get_tree().quit()

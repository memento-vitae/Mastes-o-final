extends Node2D
var file=File.new()
var localsave="save/savefase.save"
var nomefase="res://teste da fase1/fase1.tscn"
func _ready():
	file.open(localsave,File.WRITE)
	file.store_string(nomefase)
	file.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

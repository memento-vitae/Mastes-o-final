extends Control

var fase:String

func _on_iniciar_pressed():
	var localSave = "Salvamento/saveSystem.save"
	var file = FileAccess.open(localSave, FileAccess.READ)
	if file != null:
		fase = file.get_as_text()
		file.close()
	else:
		fase = "res://Fases/fase1.tscn"
		file = FileAccess.open(localSave,FileAccess.WRITE)
		if file == null:
			printerr("Algo de Errado Criar um Arquivo de save")
		else:
			file.store_string(fase)
			file.close()
	get_tree().change_scene_to_file(fase)

func _on_sair_pressed():
	get_tree().quit()

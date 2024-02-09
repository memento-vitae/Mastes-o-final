extends CanvasLayer

var menu = "res://Menus/Principal/Menu_Principal.tscn"

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		fechar_menu()

func abrir_menu():
	get_tree().paused = true
	visible = true
	
func fechar_menu():
	$Timer.start()
	await $Timer.timeout
	get_tree().paused = false
	visible = false
	
func _on_btn_sair_pressed():
	await fechar_menu()
	get_tree().change_scene_to_file(menu)

func _on_btn_voltar_pressed():
	fechar_menu()


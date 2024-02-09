extends Node

@onready var inimigo := get_owner() as InimigoBase
@export var tamanho_area:int = 200

signal saiu_da_area()

var ativado:bool

func _process(_delta):
	if ativado:
		inimigo.criar_caminho(inimigo.jogador.global_position)
		if inimigo.distancia_para_caminho() > tamanho_area:
			emit_signal("saiu_da_area")

func desativar_perseguicao():
	ativado = false

func ativar_perseguicao():
	ativado = true

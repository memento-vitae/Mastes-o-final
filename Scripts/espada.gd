extends Node2D

var direcao:Vector2
var jogador:Jogador

signal ataque()

func _ready():
	jogador = get_owner()

func ativarEspada():
	self.process_mode = self.PROCESS_MODE_INHERIT
	self.visible = true

func desativarEspada():
	self.process_mode = self.PROCESS_MODE_DISABLED
	self.visible = false

func _process(_delta):
	animacao()

#função de girar a espada
func animacao():
	direcao = jogador.dir
	if(direcao.x < 0):
		scale = Vector2(1,1)
		z_index=0
	elif(direcao.x > 0):
		scale = Vector2(-1,1)
		z_index = 0
	elif(direcao.y > 0):
		scale =  Vector2(1,1)
		z_index = 0
	elif(direcao.y < 0):
		scale = Vector2(-1,1)
		z_index = -1

func atacar():
	if(direcao.y < 0):
		$AnimationPlayer.play("ataque_cima")
	else:
		$AnimationPlayer.play("ataque")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("parar")

func hit():
	emit_signal("ataque")

func _on_jogador_emitir_hit():
	atacar()

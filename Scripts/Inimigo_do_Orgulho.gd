extends InimigoBase

var FORMA_LIMITE:int = 2
var forma:int = 1
var t:bool

var vel_inicial

func _ready():
	super()
	vel_inicial = vel_atual

#@override (não é preciso, mas eu quero escrever :) )
func animacao():
	if t == false:
		var s = "Forma_" + String.num(forma) + "/"
		if dir == Vector2.DOWN:
			s += "Baixo"
		elif dir == Vector2.UP:
			s += "Cima"
		elif dir == Vector2.RIGHT:
			s += "Direita"
		elif dir == Vector2.LEFT:
			s += "Esquerda"
		else:
			return
		$AnimationPlayer.play(s)

func corrida(novoLimite:float, velocidade:int):
	vel_atual = novoLimite
	
func desativar_corrida():
	vel_atual = vel_inicial

func tomou_dano(dano:int):
	$AnimationPlayer.play("Interacoes/SofrerDano")
	t = true
	await $AnimationPlayer.animation_finished
	ativar_perseguicao()
	mudar_forma()

func mudar_forma():
	forma += 1
	if forma > FORMA_LIMITE:
		if is_instance_valid(self): queue_free()
		forma = FORMA_LIMITE
	$AnimationPlayer.play("Mudanca_De_Forma/" + String.num(forma))

func ativar_perseguicao():
	$CampoDeVisao.desativar_visao()
	$SeguirCaminho.desativar_caminho()
	$PerseguirJogador.ativar_perseguicao()
	corrida(vel_inicial*2, 1)

func desativar_perseguicao():
	$CampoDeVisao.ativar_visao()
	$SeguirCaminho.ativar_caminho()
	$PerseguirJogador.desativar_perseguicao()
	desativar_corrida()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Interacoes/SofrerDano":
		$Sprite2D.modulate = Color("#FFFFFF")
		t = false

func _on_area_de_visao_permaneceu_na_area():
	ativar_perseguicao()

func _on_perseguir_jogador_saiu_da_area():
	desativar_perseguicao()

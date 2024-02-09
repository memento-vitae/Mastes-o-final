extends Node2D

#variaveis
const CENA_FLECHA:PackedScene = preload("res://Cenas/armas/flecha.tscn")

var flecha_vel:int = 450
var jogador:Jogador
var rotacao:float
var move:Vector2

enum Estado {MIRANDO, ATIRANDO, RECARREGANDO, DESATIVADO}
var state:Estado = Estado.DESATIVADO

func _ready():
	if get_owner() as Jogador:
		jogador = get_owner()

#girar a flecha
func mirar():
	self.visible = true
	if(state != Estado.ATIRANDO):
		$Direcao.look_at(get_global_mouse_position())
		$Direcao.rotation_degrees = wrapf($Direcao.rotation_degrees,0,360)
		rotacao = $Direcao.rotation_degrees
		if (state == Estado.DESATIVADO):
			state = Estado.MIRANDO
		__animarArco()
	return __anguloParaDirecao()

func __anguloParaDirecao():
	if rotacao >= 315 || rotacao < 45:
		return Vector2.RIGHT
	elif rotacao >= 45 && rotacao < 135:
		return Vector2.DOWN
	elif rotacao < 225:
		return Vector2.LEFT
	else:
		return Vector2.UP

func desativarArco():
	self.visible = false
	state = Estado.DESATIVADO

#chamar animaçaõ
func __animarArco():
	var r = __anguloParaDirecao()
	
	if state == Estado.ATIRANDO:
		$AnimationPlayer.speed_scale = 1.5
		if(r == Vector2.RIGHT):
			$AnimationPlayer.play("direita")
		elif(r == Vector2.LEFT):
			$AnimationPlayer.play("esquerda")
		elif(r == Vector2.UP):
			$AnimationPlayer.play("cima")
		else:
			$AnimationPlayer.play("baixo")
	else:
		$AnimationPlayer.speed_scale = 1
		if(r == Vector2.RIGHT):
			$AnimationPlayer.play("Descanco (direita)")
		elif(r == Vector2.LEFT):
			$AnimationPlayer.play("Descanco (esquerda)")
		elif(r == Vector2.UP):
			$AnimationPlayer.play("Descanco (cima)")
		else:
			$AnimationPlayer.play("Descanco (baixo)")
	
#atirar
func atirar():
	if (state == Estado.MIRANDO):
		state = Estado.ATIRANDO
		__animarArco()

func __atirar():
	if (!visible):
		state = Estado.DESATIVADO
	if(state == Estado.ATIRANDO):
		var flecha_instancia = CENA_FLECHA.instantiate()
		
		flecha_instancia.rotation_degrees = rotacao
		flecha_instancia.global_position = $"OrigemFlecha".global_position
		flecha_instancia.vuar(rotacao, flecha_vel)
		flecha_instancia.jogador = jogador
		$Flechas.add_child(flecha_instancia)
		$Timer.start()
		
		state = Estado.RECARREGANDO
	
#recarregar
func _on_Timer_timeout():
	state = Estado.MIRANDO

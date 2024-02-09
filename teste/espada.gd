extends Node2D

#variaveis
var girar=false
var batendo = false
var poder
#função de girar a espada
func _startatk(var atk, var move:Vector2,var espada):
	poder=true
	if(move.x<0):
		$".".z_index=0
		$".".position=Vector2(6,7)
		scale=Vector2(1,1)
	elif(move.x>0):
		$".".z_index=0
		scale=Vector2(-1,1)
		$".".position=Vector2(-6,7)
	elif(move.y>0):
		$".".z_index=0
		scale=Vector2(1,1)
		$".".position=Vector2(7,7)
	elif(move.y<0):
		$".".z_index=-1
		scale=Vector2(-1,1)
		$".".position=Vector2(-6,7)
	if(atk || batendo):
		batendo=true
		atacar(move,espada)
	else:
		animacaoparado(espada)

#animar a espada atacando
func atacar(var move:Vector2,var espada):
	if(espada==1):
		if(move.y<0):
			$AnimationPlayer.play("atk_d_frente1")
		else:
			$AnimationPlayer.play("atk1")
	else:
		$AnimationPlayer.play("atk2")

#rodar animação parado
func animacaoparado(var espada):
	if(espada==1):
		$AnimationPlayer.play("stop1")
	else:
		$AnimationPlayer.play("stop2")

#identificar se a animação já terminou
func bateu():
	batendo=false

func hit1():
	poder=!poder

func colisao():
	return poder;

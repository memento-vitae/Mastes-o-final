extends Node2D

#variaveis
var vel=450
var move=Vector2()
var rodar=0
var rodarad=0#radianos
var atirar
var recarregando=false
var olhar=Vector2()
onready var pizza = preload("res://teste/flecha.tscn")
var mouse=Vector2()
var flip=0
var mirar_atual_rad
var atirando=false

#girar a flecha
func mirar():
	if(!atirando):
		mouse=get_global_mouse_position()
		$Sprite.look_at(mouse)
		atirando=true

#olhar para o mouse
func look_at_mouse(var aparece):
	if(aparece):
		$".".visible=true
		if(atirando):
			$Sprite.rotation_degrees=wrapf($Sprite.rotation_degrees,0,360)
			rodar=$Sprite.rotation_degrees
			rodarad=deg2rad(rodar)

#ver se  clicou em atirar
func _input(event):
	if Input.is_action_pressed("atirar"):
		atirar=true
	else:
		atirar=false
	animararco()
	
#chamar animaçaõ
func animararco():
	if(atirar && !recarregando):
		animacao()
	elif(recarregando):
		if(olhar==Vector2(1,0)):
			$AnimationPlayer.play("paradox+")
		elif(olhar==Vector2(-1,0)):
			$AnimationPlayer.play("paradox-")
		elif(olhar==Vector2(0,1)):
			$AnimationPlayer.play("paradoy-")
		else:
			$AnimationPlayer.play("paradoy+")

#animar flecha atirando
func animacao():
	if(rodar>=315 || rodar<=45):
		z_index=0
		$AnimationPlayer.play("eixox+")
		flip=1
	elif(rodar>=135 && rodar<=225):
		z_index=0
		$AnimationPlayer.play("eixox-")
		flip=3
	elif(rodar<315 && rodar>225):
		z_index=-1
		$AnimationPlayer.play("eixoy+")
		flip=4
	else:
		z_index=0
		$AnimationPlayer.play("eixoy-")
		flip=2

#atirar
func atirar():
	if(!recarregando && visible):
		var de=pizza.instance()
		de.rotation_degrees=rodar
		de.global_position=global_position
		$Node2D.add_child(de)
		de.vuar(rodarad,vel)
		$Timer.start()
		atirando=false
		recarregando=true

#recarregar
func _on_Timer_timeout():
	recarregando=false

#girar o player
func flipar():
	return flip

#direção da flecha
func receberdirect(var direct= Vector2()):
	olhar=direct

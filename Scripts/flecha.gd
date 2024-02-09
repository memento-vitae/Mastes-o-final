extends Node2D

class_name Flecha

#variaveis
var dir = Vector2.ZERO
var mov = Vector2.ZERO
var jogador:Jogador
var vel_inicial
var caiu=false

func _ready():
	visible = true

#define o angulo da flecha e sua velocidade e o tempo de voo
func vuar(rad, vel):
	var r = deg_to_rad(rad)
	dir.x = cos(r)
	dir.y = sin(r)
	mov = dir.normalized() * vel
	vel_inicial = vel

#função com o intuito de deslocar a flecha
func _physics_process(delta):
	position += mov * delta
	if mov.length_squared() <= 1.0: #verifica a velocidade da flecha
		mov = Vector2.ZERO #iguala a 0
		if(!caiu):
			desativar_flecha()
			$Timer.start()#começa o tempo para ela sumir
			caiu = true
	else:
		mov -= dir.normalized() * (vel_inicial * delta)

func desativar_flecha():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)	

#sumir
func _on_Timer_timeout():
	queue_free()

func _on_Area2D_area_entered(area):
	jogador.causar_dano(area.owner)
	desativar_flecha()
	queue_free()

func _on_area_2d_body_entered(_body):
	desativar_flecha()
	mov = Vector2.ZERO

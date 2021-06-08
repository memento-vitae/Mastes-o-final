extends KinematicBody2D

#variaveis
var  hamburguer=Vector2()
var Mcs
var caiu=false
var dano=5

#função que inicia a flecha
func _ready():
	visible=false
	pass;

#define o angulo da flecha e sua velocidade e o tempo de voo
func vuar(var rad,var vel):
	hamburguer.x=cos(rad)*vel
	hamburguer.y=sin(rad)*vel
	Mcs=hamburguer.normalized()*150

#função com o intuito de deslocar a flecha
func _physics_process(delta):
	visible=true
	hamburguer=move_and_slide(hamburguer,Vector2(0,1))
	if hamburguer.length_squared() <= 1.0: #verifica a velocidade da flecha
		hamburguer = Vector2() #iguala a 0
		if(!caiu):
			$Timer.start()#começa o tempo para ela sumir
			caiu=true
	else:
		hamburguer -= Mcs * delta#reduzir a velocidade
		caiu=false

#dar dano
func _on_Area2D_body_entered(body):
	body.dano(dano)
	hamburguer=Vector2()
	queue_free()
	
#sumir
func _on_Timer_timeout():
	queue_free()

#verifica se bateu em uma parede
func _on_parede_body_entered(body):
	hamburguer=Vector2()

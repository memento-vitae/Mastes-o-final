extends KinematicBody2D

export var vel_principal:int = 60
var state:int = 2 #0 - Hit, 1 - Seguir o Jogador, 2 - Próximo, 3 - Distante
var velocidade = vel_principal
var movimento:Vector2
var player = null
var navigation:Navigation2D = null
var path: Array = []
var dir:int = 0 #0-cima, 1-direita, 2-baixo, 3-esquerda


func _ready():
	#Responsável por pegar o objeto que está no grupo Player/Navigation e colocar na varível player/navigation
	if get_tree().has_group("Player"):
		player = get_tree().get_nodes_in_group("Player")[0]
	if get_tree().has_group("Navigation"):
		navigation = get_tree().get_nodes_in_group("Navigation")[0]

func _physics_process(_delta):
	if player != null && navigation != null:
		if state == 1: 
			criar_caminho()
		if state == 2 || state == 3:
			path.clear()
			velocidade = 0
	if Input.is_key_pressed(KEY_P): #Apenas para testar a efeito de Hit do inimigo
		$Hit.play("Hit")
		
	if state == 2:
		$Campo_de_visao.visible = true
		campo_de_visao()
	else:
		$Campo_de_visao.visible = false
	move()

#Responsável por criar o caminho que o inimigo vai seguir
func criar_caminho():
	path = navigation.get_simple_path(global_position, player.global_position, false)
	if path.size() > 0:
		movimento = global_position.direction_to(path[1])
	else:
		movimento = Vector2(0,0)

#Responsavel pela movimentação
func move():
	if state == 1:
		velocidade = vel_principal
	elif state == 0:
		velocidade = 0
	movimento *= velocidade
	movimento = move_and_slide(movimento)
	direcao(movimento)

#Responsável por definir qual direção o inimigo está olhando, baseado na utltima direção que ele estava andando
#Caso o inimigo estiver se movimento para mais de uma direção, o maior valor é quem define a direção
func direcao(move:Vector2):
	var cpy = move 
	if move.x < 0: 
		cpy.x *= -1
	if move.y < 0: 
		cpy.y *= -1
	
	if cpy.y > cpy.x:
		if move.y < 0: dir = 0
		else: dir = 2
	elif cpy.x > cpy.y:
		if move.x < 0: dir = 3
		else: dir = 1

#Responsável por fazer o inimigo perceber coisas que estão na sua frente, e se for o jogador, ele segue
func campo_de_visao():
	var rot = $Campo_de_visao.rotation_degrees
	var d:int = -1 #0-cima, 1-direita, 2-baixo, 3-esquerda
	
	$Campo_de_visao.look_at(player.position)
	rot = wrapf(rot, 0, 360)
	#Determina um intervalo de ângulos para cada direção
	if (rot >= 0 && rot <= 45) || (rot <= 360 && rot >= 316): d = 1
	elif (rot >= 46 && rot <= 135): d = 2
	elif (rot >= 136 && rot <= 225): d = 3
	elif (rot >= 226 && rot <= 316): d = 0 
	if d == dir:
		$Campo_de_visao.enabled = true #Não é necessário para funcionar (eu acho :))
		if is_instance_valid($Campo_de_visao.get_collider()):
			if $Campo_de_visao.get_collider().get_parent() == player:
				state = 1
	else: $Campo_de_visao.enabled = false #Não é necessário para funcionar (eu acho :))

#Responsável por ligar/desligar o estado de sofrer dano do inimigo
func hit_effect(var ativar:bool):
	if ativar:
		state = 0
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite.material.set_shader_param("is_white", true)
	else:
		state = 1
		$CollisionShape2D.set_deferred("disabled", false)
		$Sprite.material.set_shader_param("is_white", false)

func _on_Area_Ataque_body_exited(body):
	if body == player:
		state = 3

func _on_Area_Ataque_body_entered(body):
	if body == player:
		state = 2

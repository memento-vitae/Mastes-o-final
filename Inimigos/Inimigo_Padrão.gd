extends KinematicBody2D

export var vel_maxima:int = 40
onready var vel_atual = vel_maxima
export var vida:int = 40
var state:int = 2 #0 - Hit, 1 - Seguir o Jogador, 2 - Aproximar do caminho, 3 - Seguir_Caminho
var dir:int = 0 #0-cima, 1-direita, 2-baixo, 3-esquerda
var move:Vector2
var path: Array = []
var movimento_liberado:bool = true
var nav_dir:bool = true

var player
var path2D:Path2D
var pathFollow:PathFollow2D
var navigation:Navigation2D
var lib:bool = true

func _ready():
	#Responsável por pegar o objeto que está no grupo Player/Navigation e colocar na varível player/navigation
	if get_tree().has_group("Player"):
		player = get_tree().get_nodes_in_group("Player")[0]
	if get_tree().has_group("Navigation"):
		navigation = get_tree().get_nodes_in_group("Navigation")[0]
	if get_tree().has_group("Path"):
		path2D = get_tree().get_nodes_in_group("Path")[0]
	
	if is_instance_valid(path2D):
		pathFollow = PathFollow2D.new()
		path2D.add_child(pathFollow)
		pathFollow.set_name(self.name)
		pathFollow.set_loop(false)
		pathFollow.set_rotate(false)
	else:
		state = 1
	if player == null || navigation == null: #Player ou navigation não existem
		breakpoint 
	if state == 2: find_path()

func _physics_process(delta):
	if movimento_liberado == true:
		movimento(delta)
	else:
		melhorar_movimento()

func melhorar_movimento():
	var livre:bool = true
	#Procura por todos os objetos do grupo inimigo que colidiram com ele, até encontrar aquele 
	#que está realizando o movimento (apenas um inimigo colidindo pode se movimentar)
	#Se existir, o inimigo continua parado, senão ele é quem vai realizar o movimento
	for x in $Hitbox.get_overlapping_areas():
		if x.get_parent().is_in_group("Inimigo"):
			if x.get_parent().movimento_liberado == true:
				livre = false
				break
	if livre == true:
		$CollisionShape2D.set_deferred("disabled", false)
		movimento_liberado = true
		
func movimento(var delta):
	var p:Vector2
	if state == 1: 
		criar_caminho(player.global_position)
	elif state == 2:
		criar_caminho(pathFollow.position)
		if path.size() == 2:
			p = path[1] - path[0]
			if (p.x < 1 && p.x > -1) && (p.y < 1 && p.y > -1):
				state = 3
	
	
	if state == 1 || state == 2:
		move *= vel_atual
		move = move_and_slide(move)
		direcao(move, 5)
	elif state == 3:
		nav_path(delta)
	
	if state == 3 || state == 2:
		campo_de_visao(true)
	else: 
		campo_de_visao(false)
	animation()

func inimigos_collidindo():
	pass

#Responsável por criar o caminho que o inimigo vai seguir
func criar_caminho(var objetivo:Vector2):
	var dif:Vector2
	path = navigation.get_simple_path(global_position, objetivo , false)
	if path.size() > 0:
		dif = global_position - path[path.size()-1]
		move = global_position.direction_to(path[1])
		if dif.x < 1 && dif.x > -1 && dif.y < 1 && dif.y > -1:
			move = Vector2(0,0)
	else:
		move = Vector2(0,0)

func nav_path(delta):
	if nav_dir == true:
		pathFollow.set_offset(pathFollow.offset + vel_atual * delta)
	else:
		pathFollow.set_offset(pathFollow.offset - vel_atual * delta)
	if pathFollow.unit_offset >= 1:
		nav_dir = false
	elif pathFollow.unit_offset <= 0:
		nav_dir = true
	
	move = move_and_slide(position.direction_to(pathFollow.global_position) * vel_atual)
	direcao(move,5)
	
	if is_on_wall() && lib == true:
		nav_dir = !nav_dir
		lib = false
	elif !is_on_wall() && lib == false:
		lib = true
	#position = pathFollow.global_position

#Responsável por definir qual direção o inimigo está olhando, baseado na utltima direção que ele estava andando
#Caso o inimigo estiver se movimento para mais de uma direção, o maior valor é quem define a direção
func direcao(var movement:Vector2, var precisao:float):
	#Precisao recomendada para o move é 5
	#Precisao recomendada para o nav_path é 0.2
	
	#Feito apenas para melhorar o movimento do inimigo
	if movement.x < precisao && movement.x > -precisao: movement.x = 0
	if movement.y < precisao && movement.y > -precisao: movement.y = 0
	if movement.x > 0:
		dir = 1
	elif movement.x < 0:
		 dir = 3
	elif movement.y > 0:
		 dir = 2
	elif movement.y < 0:
		 dir = 0 

func find_path():
	var x:int = 0
	var dif:Vector2
	var menor_dif:Vector2 = Vector2(0,0)
	var index:int
	
	state = 2
	while (x < path2D.curve.get_point_count()):
		dif = global_position - path2D.curve.get_point_position(x)
		if dif.x < 0: dif.x *= -1
		if dif.y < 0: dif.y *= -1
		
		if menor_dif == Vector2(0,0):
			menor_dif = dif
		elif (dif.x + dif.y) < (menor_dif.x + menor_dif.y):
			menor_dif = dif
			index = x
		x += 1
	pathFollow.offset = path2D.curve.get_closest_offset(path2D.curve.get_point_position(index))
	
#Responsável por fazer o inimigo perceber coisas que estão na sua frente, e se for o jogador, ele segue
func campo_de_visao(ativar:bool):
	if ativar:
		$Campo_de_visao.visible = true
		$Campo_de_visao/Coll.set_deferred("disabled", false) 
		
		if dir == 1: $Campo_de_visao/Coll.rotation_degrees = 0
		elif dir == 2: $Campo_de_visao/Coll.rotation_degrees = 90
		elif dir == 3: $Campo_de_visao/Coll.rotation_degrees = 180
		elif dir == 0: $Campo_de_visao/Coll.rotation_degrees = 270
		
		for x in $Campo_de_visao.get_overlapping_areas():
			if x.get_parent() == player:
				$Campo_de_visao/Visao.cast_to.x = sqrt(pow(position.x - player.position.x,2) + pow(position.y - player.position.y,2))
				$Campo_de_visao/Visao.enabled = true
				$Campo_de_visao/Visao.look_at(player.position)
				$Campo_de_visao/Visao.rotation_degrees = wrapf($Campo_de_visao/Visao.rotation_degrees, 0, 360)
				if $Campo_de_visao/Timer.time_left == 0: $Campo_de_visao/Timer.start()
			else:
				$Campo_de_visao/Visao.visible = true
	else:
		$Campo_de_visao.visible = false
		$Campo_de_visao/Coll.set_deferred("disabled", true)
		$Campo_de_visao/Visao.enabled = false
	
func dano(var dano):
	$Hit.play("Hit")
	vida -= dano
	if(vida<1):
		if is_instance_valid(self): .queue_free()

#Responsável por ligar/desligar o estado de sofrer dano do inimigo
func hit_effect(var ativar:bool):
	if ativar:
		state = 0
	else:
		state = 1

func animation(): 
	if dir == 0:
		$Andar.play("Cima")
	elif dir == 1:
		$Andar.play("Direita")
	elif dir == 2:
		$Andar.play("Baixo")
	elif dir == 3:
		$Andar.play("Esquerda")	
	
#Responsável por melhorar o movimento do inimigo
func _on_Hitbox_area_entered(area):
	var outro = area.get_parent()
	if outro.is_in_group("Inimigo") && movimento_liberado == true:
		outro.get_node("CollisionShape2D").set_deferred("disabled", true)
		outro.movimento_liberado = false
	
func _on_Area_Ataque_body_exited(body):
	if body == player && state != 3 && state != 2:
		find_path()
	
func _on_Timer_timeout():
	if is_instance_valid($Campo_de_visao/Visao.get_collider()):
		if $Campo_de_visao/Visao.get_collider().get_parent() == player || $Campo_de_visao/Visao.get_collider() == player:
			state = 1

extends CharacterBody2D

class_name InimigoBase

@export var vel_maxima:int = 40
@export var vida:int = 40

@onready var navAgent:NavigationAgent2D = $NavigationAgent2D
@onready var vel_atual:int = vel_maxima

var jogador:Jogador
var alvo:Vector2
var dir:Vector2
var rot:float

const OFFSET_MOVIMENTO = Vector2(0.5, 0.5)

func _ready():
	if get_tree().has_group("Jogador"):
		jogador = get_tree().get_nodes_in_group("Jogador")[0]
	else: breakpoint 
	alvo = jogador.global_position

func _physics_process(_delta):
	movimento()

func _process(_delta):
	animacao()

func movimento():
	var move = correcao(alvo - self.global_position, OFFSET_MOVIMENTO).normalized()
	set_velocity(move*vel_atual)
	direcao(velocity)
	move_and_slide()

func inimigos_collidindo():
	pass

func correcao(movement:Vector2, precisao:Vector2):
	if abs(movement.x) < precisao.x: movement.x = 0
	if abs(movement.y) < precisao.y: movement.y = 0
	return movement

#Responsável por definir qual direção o inimigo está olhando, baseado na utltima 
#direção que ele estava andando
func direcao(move:Vector2):
	if abs(move.x) >= abs(move.y):
		if move.x > 0:
			rot = 0
			dir = Vector2.RIGHT
		else:
			rot = 180
			dir = Vector2.LEFT
	elif move.y != 0:
		if move.y > 0:
			rot = 90
			dir = Vector2.DOWN
		else:
			rot = 270
			dir = Vector2.UP

func criar_caminho(objetivo:Vector2):
	navAgent.target_position = objetivo
	alvo = navAgent.get_next_path_position()

func distancia_para_caminho() -> float:
	return navAgent.distance_to_target()

func tomou_dano(dano:int):
	$AnimationPlayer.play("Interacoes/SofrerDano")
	vida -= dano
	if(vida < 1):
		if is_instance_valid(self): self.queue_free()

func animacao(): 
	if dir == Vector2.DOWN:
		$AnimationPlayer.play("Movimento/Baixo")
	elif dir == Vector2.UP:
		$AnimationPlayer.play("Movimento/Cima")
	elif dir == Vector2.RIGHT:
		$AnimationPlayer.play("Movimento/Direita")
	elif dir == Vector2.LEFT:
		$AnimationPlayer.play("Movimento/Esquerda")

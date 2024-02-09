extends Node2D

signal causou_dano(valor_dano:int, direcao:Vector2)

@onready var inimigo := get_owner() as InimigoBase
@export var valor_dano:int = 1

var v

func _ready():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	
	await $Area2D.area_entered
	connect("causou_dano", Callable(inimigo.jogador, "receber_dano") )

func _process(_delta):
	var v:int = inimigo.vel_maxima
	self.rotation = deg_to_rad(inimigo.rot)
	
	if $RayCast2D.is_colliding():
		ativar_ataque()

func animar_ataque():
	if inimigo.vel_atual != 4:
		v = inimigo.vel_atual
	inimigo.vel_atual = 4
	$AnimationPlayer.play("Efeito_Hit");
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("RESET")

func dano():
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	await $AnimationPlayer.animation_finished
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	inimigo.vel_atual = v

func ativar_ataque():
	animar_ataque()

func desativar_ataque():
	pass

func _on_area_2d_area_entered(_area):
	emit_signal("causou_dano", valor_dano, inimigo.dir)

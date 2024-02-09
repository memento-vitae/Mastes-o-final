extends CharacterBody2D

class_name Jogador

#TODO MELGORAR O CONCEITO DE VELOCIDADE

@export var velocidade_max = 80
@export var stamina_max = 100
@export var vidamax:int
@export var dano: int
@export var vida:int

@onready var vel_at = velocidade_max
@onready var stamina = stamina_max

signal emitir_hit()

const CUSTO_DASH = 30

var controle_desativado:bool = false
var dir:Vector2 = Vector2.RIGHT
var dash_cowndown:bool = true
var colidiu:bool = false
var move:Vector2
var mirando:bool

func _ready():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

func _physics_process(_delta):
	if !controle_desativado:
		move.x = Input.get_axis("ui_left","ui_right") 
		move.y = Input.get_axis("ui_up","ui_down")
		dir = animation(move)
		if mirando:
			vel_at = velocidade_max / 4.0
	if mirando:
		animation($"Arco".mirar())
	if controle_desativado:
		move = dir
	
	set_velocity(move.normalized() * vel_at)
	colidiu = move_and_slide()

func _unhandled_input(event):
	if (Input.is_action_pressed("atk")):
		emit_signal("emitir_hit")
	
	if (Input.is_action_just_pressed("dash") == true && stamina > CUSTO_DASH):
		if dash_cowndown:
			dash_cowndown = false
			ativar_dash()
	
	if (Input.is_action_just_pressed("atirar")):
		$Arco.atirar()
	
	if Input.is_action_just_pressed("pause"):
		$Pause.abrir_menu()
	
	if(Input.is_action_pressed("mirar")):
		$Espada.desativarEspada()
		mirando = true
	elif(Input.is_action_just_released("mirar")):
		$Espada.ativarEspada()
		$"Arco".desativarArco()
		vel_at = velocidade_max
		mirando = false

#define as animações
func animation(direcao:Vector2) -> Vector2:
	if(direcao.x < 0):
		$AnimationPlayer.play("Andando (E)")
		return Vector2.LEFT
	elif(direcao.x > 0):
		$AnimationPlayer.play("Andando (D)")
		return Vector2.RIGHT
	elif(direcao.y > 0):
		$AnimationPlayer.play("Andando (B)")
		return Vector2.DOWN
	elif(direcao.y < 0):
		$AnimationPlayer.play("Andando (C)")
		return Vector2.UP
	else:
		if(dir == Vector2.DOWN):
			$AnimationPlayer.play("Parado (B)")
		elif(dir == Vector2.UP):
			$AnimationPlayer.play("Parado (C)")
		else:
			$AnimationPlayer.play("Parado (Horizontal)")
		return dir

func ativar_dash():
	var spr:Sprite2D
	var escala = 4
	var quant = 6
	
	if !controle_desativado:
		controle_desativado = true
		$HitBox/CollisionPolygon2D.set_deferred("disabled", true)
		for i in range(quant):
			if get_real_velocity() == Vector2.ZERO:
				break
			spr = $Jogador.duplicate()
			spr.modulate = Color(1,1,1, 0.15 * (i+1))
			spr.global_position = $Jogador.global_position - dir * (quant-i)
			
			stamina -= CUSTO_DASH/quant
			vel_at = velocidade_max * escala
			get_tree().current_scene.add_child(spr)
			
			await get_tree().create_timer(0.03).timeout
			
			get_tree().create_timer(0.07*i).connect("timeout", spr.queue_free)
			escala -= (escala-1)/quant
			
		$HitBox/CollisionPolygon2D.set_deferred("disabled", false)
		controle_desativado = false
		vel_at = velocidade_max
		_unhandled_input(null)
	await get_tree().create_timer(0.3).timeout
	dash_cowndown = true

func receber_dano(valor_dano:int, direcao:Vector2):
	if !controle_desativado:
		$HitBox/CollisionPolygon2D.set_deferred("disabled", true)
		self.modulate = Color(1,0,0,0.75)
		controle_desativado = true
		vel_at = velocidade_max * 1.5
		dir = direcao
		
		await get_tree().create_timer(0.15).timeout
		
		$HitBox/CollisionPolygon2D.set_deferred("disabled", false)
		self.modulate = Color(1,1,1,1)
		controle_desativado = false
		vel_at = velocidade_max	
		vida -= valor_dano
		
		if(vida <= 0):
			print("YOU ARE DIE")

func causar_dano(alvo:InimigoBase):
	alvo.tomou_dano(dano)

#dar dano nos inimigos
func _on_Area2D_area_entered(area):
	causar_dano(area.get_owner())

func _on_recuperar_stamina_timeout():
	stamina += 5
	if (stamina >= stamina_max):
		stamina = stamina_max

func _on_espada_ataque():
	$Area2D/CollisionShape2D.set_deferred("disabled", false);
	await get_tree().create_timer(0.1).timeout
	$Area2D/CollisionShape2D.set_deferred("disabled", true);

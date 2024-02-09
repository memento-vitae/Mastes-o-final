extends Area2D

signal entrou_na_area()
signal permaneceu_na_area()
signal saiu_da_area()

@onready var inimigo := get_owner() as InimigoBase
var jogador:Jogador
var ativado:bool

func ativar_visao():
	$CollisionPolygon2D.set_deferred("disabled", false)

func desativar_visao():
	$CollisionPolygon2D.set_deferred("disabled", true)
	ativado = false

func _process(_delta):
	var alvo:float
	$CollisionPolygon2D.rotation = deg_to_rad(inimigo.rot)
	if ativado:
		alvo = pow(jogador.global_position.x - global_position.x, 2)
		alvo += pow(jogador.global_position.y - global_position.y, 2)
		$RayCast2D.target_position.x = sqrt(alvo)
		$RayCast2D.look_at(jogador.position)
		emit_signal("entrou_na_area")
		if $Timer.time_left == 0: 
			$Timer.start()

func _on_timer_timeout():
	if $RayCast2D.get_collider() != null:
		if $RayCast2D.get_collider() as Jogador:
			emit_signal("permaneceu_na_area")

func _on_body_entered(body):
	if body as Jogador:
		jogador = body
		$RayCast2D.enabled = true
		ativado = true

func _on_body_exited(_body):
	emit_signal("saiu_da_area")
	ativado = false
	$Timer.stop()

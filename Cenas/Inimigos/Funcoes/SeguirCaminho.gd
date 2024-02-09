extends Node2D

enum Modos {APROXIMAR, SEGUIR, DESATIVADO}
var pathFollow2D:PathFollow2D
var inimigo:InimigoBase
var velocidade:int
var path:Path2D
var modo:Modos

func _ready():
	#print(get_tree().current_scene) //Pega a fase onde o jogo se passa
	#print(get_owner()) //Pega o node principal que contem o script
	if self.get_owner() as InimigoBase:
		inimigo = get_owner()
	else:
		printerr("O módulo de SeguirCaminho não estar em um node válido")
		breakpoint

	if (inimigo.get_parent() as Path2D):
		path = inimigo.get_parent()
	
	if path == null:
		printerr("O inimigo não pertence a nenhum caminho")
		breakpoint
	
	pathFollow2D = PathFollow2D.new()
	path.add_child.call_deferred(pathFollow2D)

func aproximar_caminho():
	var pos = inimigo.global_position
	$Marker2D.global_position = path.curve.get_closest_point(pos)
	
	if abs(pos - $Marker2D.global_position) < inimigo.OFFSET_MOVIMENTO:
		pathFollow2D.progress = path.curve.get_closest_offset(pos)
		velocidade = inimigo.vel_atual
		modo = Modos.SEGUIR
	else:
		inimigo.criar_caminho($Marker2D.global_position)
	
func _process(delta):
	if modo == Modos.SEGUIR:
		if abs(pathFollow2D.global_position - global_position) > Vector2(5,5):
			inimigo.criar_caminho(pathFollow2D.global_position)
		else:
			pathFollow2D.progress += (delta*velocidade)
			inimigo.alvo = pathFollow2D.global_position
	elif modo == Modos.APROXIMAR:
		aproximar_caminho()

func _exit_tree():
	pathFollow2D.queue_free()

func ativar_caminho():
	modo = Modos.APROXIMAR
	
func desativar_caminho():
	inimigo.alvo = inimigo.jogador.global_position
	modo = Modos.DESATIVADO

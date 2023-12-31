extends KinematicBody2D

#variaveis exportadas, caso elas necessitam de interferencia externa
export var espada: int
export var dano: int
export var velocidade = 300
export var stamina = 100
var fase 
export var vida:int
export var vidamax:int

#variaveis usadas para ações secundarias
var coin = 0
var direct= Vector2()
var move = Vector2()

#variaveis de movimento
var controll = {
	'up':false,
	'down':false,
	'left':false,
	'right':false,
	'dash':false,
	'atk': false,
	'flecha':false,
}
#variaveis para save
var array=[]#salvar dados
var file = File.new()
var localsave="save/saveMygame.save"
#é aqui em que o codigo começa
func _ready():
	fase=get_parent()
func _physics_process(delta):
	
	if file.file_exists(localsave):
		file.open(localsave, File.READ)
		#print(file.get_var())
		file.close()
	else:
		array=[espada,dano,coin, $".".global_position,vidamax]
		file.open(localsave, File.WRITE)
		file.store_var(array)
		file.close()
	controll_loop()
	mooviment_loop(delta)
	$"talvez seja um arco".look_at_mouse(self.controll['flecha'])

#essa função serve para saber oque o jogador está apretando
func controll_loop():
	self.controll['up']=Input.is_action_pressed("ui_up")#Wcima
	self.controll['down']=Input.is_action_pressed("ui_down")#Sbaixo
	self.controll['left']=Input.is_action_pressed("ui_left")#Aesquerda
	self.controll['right']=Input.is_action_pressed("ui_right")#Ddireita
	
	self.controll['dash']=Input.is_action_pressed("dash")#Ecorrer
	
	self.controll['atk']=Input.is_action_pressed("atk")#Spaceataque
	self.controll['flecha']=Input.is_action_pressed("flecha")#botão direito do mouse

#essa serve pare o personagem se mover
func mooviment_loop(delta):
	walk()
	$Area2D/CollisionShape2D.set_deferred("disabled",$espadinha.colisao());
	atacar()#acho que dá para por na processo fisico
	var movimento = (move*velocidade)
	if(self.controll['dash']==true && stamina>0):
		movimento=movimento*2
		stamina=stamina-1
	elif(stamina<100 && movimento == Vector2(0,0)):
		stamina=stamina+1
		
	movimento=move_and_slide(movimento, Vector2(0 , 1))

#essa indica a direção em que ela está andando
func walk():
	move.x=-int(controll.left)+int(controll.right)
	move.y=-int(controll.up)+int(controll.down)

#serve para que o ataque seja executado
func atacar():
	var flip
	if(!self.controll['flecha']):
		$Area2D.set_deferred("disabled",true)
		animation()
		$"talvez seja um arco".visible=false
		$espadinha.visible=true
		$espadinha._startatk(self.controll['atk'],direct,espada)
	else:
		$"talvez seja um arco".visible=true
		$espadinha.visible=false
		flip = $"talvez seja um arco".flipar()
		$"talvez seja um arco".receberdirect(direct)
		animation_flecha(flip)

#define as animações
func animation():
	if(move.x<0):
		$AnimatedSprite.play("andar(H)")
		$AnimatedSprite.flip_h=true
		$Area2D/CollisionShape2D.rotation_degrees=0
		$Area2D/CollisionShape2D.position=Vector2(-9,3)
		direct=Vector2(-1,0)
	elif(move.x>0):
		$AnimatedSprite.play("andar(H)")
		$AnimatedSprite.flip_h=false
		$Area2D/CollisionShape2D.rotation_degrees=0
		$Area2D/CollisionShape2D.position=Vector2(9,3)
		direct=Vector2(1,0)
	elif(move.y>0):
		$AnimatedSprite.play("andar(B)")
		$Area2D/CollisionShape2D.rotation_degrees=-90
		$Area2D/CollisionShape2D.position=Vector2(0,10)
		direct=Vector2(0,1)
	elif(move.y<0):
		$AnimatedSprite.play("andar(C)")
		$Area2D/CollisionShape2D.rotation_degrees=-90
		$Area2D/CollisionShape2D.position=Vector2(0,-2)
		direct=Vector2(0,-1)
	elif(move==Vector2(0,0)):
		if(direct.x!=0):
			$AnimatedSprite.play("parado(H)")
		elif(direct.y>0):
			$AnimatedSprite.play("parado(B)")
		elif(direct.y<0):
			$AnimatedSprite.play("parado(C)")

#animação com a flecha, para ele olhar para onde está mirando
func animation_flecha(var flip):
	if(move!=Vector2()):
		if(flip==3):
			$AnimatedSprite.play("andar(H)")
			$AnimatedSprite.flip_h=true
			direct=Vector2(-1,0)
		elif(flip==1):
			$AnimatedSprite.play("andar(H)")
			$AnimatedSprite.flip_h=false
			direct=Vector2(1,0)
		elif(flip==2):
			$AnimatedSprite.play("andar(B)")
			direct=Vector2(0,1)
		elif(flip==4):
			$AnimatedSprite.play("andar(C)")
			direct=Vector2(0,-1)
	else:
		if(flip==1):
			$AnimatedSprite.play("parado(H)")
			$AnimatedSprite.flip_h=false
			direct=Vector2(1,0)
		elif(flip==2):
			$AnimatedSprite.play("parado(B)")
			direct=Vector2(0,1)
		elif(flip==3):
			$AnimatedSprite.play("parado(H)")
			$AnimatedSprite.flip_h=true
			direct=Vector2(-1,0)
		elif(flip==4):
			$AnimatedSprite.play("parado(C)")
			direct=Vector2(0,-1)

#acho que ele ainda não morre, mas isso não posso afirmar
func die(var dano):
	vida-=dano
	if(vida<=0):
		print("YOU ARE DIE")
		queue_free()

#imagino que tenha dinheiro
func coinadd(var moedas:int):
	coin+=moedas

#dar dano nos inimigos
func _on_Area2D_area_entered(area):
	print("pdh")
	area.get_parent().dano(dano)

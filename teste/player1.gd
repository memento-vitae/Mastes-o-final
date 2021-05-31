extends KinematicBody2D

#variaveis exportadas, caso elas necessitam de interferencia externa
export var espada: int
export var dano: int
export var velocidade = 300
export var stamina = 100
export var fase = ""

#variaveis usadas para ações secundarias
var coin = 0
var direct= Vector2()
var move = Vector2()
export var vida:int

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

#é aqui em que o codigo começa
func _physics_process(delta):
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
		$Area2D/CollisionShape2D.position=Vector2(-7,5)
		direct=Vector2(-1,0)
	elif(move.x>0):
		$AnimatedSprite.play("andar(H)")
		$AnimatedSprite.flip_h=false
		$Area2D/CollisionShape2D.position=Vector2(6,5)
		direct=Vector2(1,0)
	elif(move.y>0):
		$AnimatedSprite.play("andar(B)")
		$Area2D/CollisionShape2D.position=Vector2(0,9)
		direct=Vector2(0,1)
	elif(move.y<0):
		$AnimatedSprite.play("andar(C)")
		$Area2D/CollisionShape2D.position=Vector2(0,1)
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
func _on_Area2D_body_entered(body):
	if(self.controll['atk']):
		body.dano(dano)

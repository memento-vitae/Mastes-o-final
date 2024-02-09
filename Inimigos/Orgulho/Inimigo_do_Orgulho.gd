extends "res://Inimigos/Inimigo_Padrão.gd"

var forma:int = 1
var FORMA_LIMITE:int = 2

#@override (não é preciso, mas eu quero escrever :) )
func animation():
	var s = "(" + String(forma) + ")"
	if $Andar.frames != null:
		if dir == 0:
			s += "Cima"
			$Andar.play(s)
		elif dir == 1:
			s += "Direita"
			$Andar.play(s)
		elif dir == 2:
			s += "Baixo"
			$Andar.play(s)
		elif dir == 3:
			s += "Esquerda"
			$Andar.play(s)

#@override (não é preciso, mas eu quero escrever :) )
func dano(var _dano):
	$Hit.play("Hit")
	mudar_forma()

func mudar_forma():
	forma += 1
	if forma > FORMA_LIMITE:
		if is_instance_valid(self): queue_free()
		forma = FORMA_LIMITE
	$Transicao.play("Forma" + String(forma))
	

extends Area2D

#Esse é o sinal que o corpo test deve emitir caso a area da luz bata nele
func _on_light_area(body):
	print(body.name)

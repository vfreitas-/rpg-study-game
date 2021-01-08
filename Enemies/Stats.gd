extends Node

# podemos especificar o tipo, porém ele faz inferencia tbm
export(int) var max_health = 1 setget set_max_health
onready var health = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	# garante que a vida nunca vai ser maior que a max_health
	#self.health = min(health, max_health)
	emit_signal("max_health_changed", value)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if (health <= 0):
		emit_signal("no_health")


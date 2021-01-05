extends Node2D

onready var animated_sprite = $AnimatedSprite

func _ready():
	animated_sprite.play("Animate")

func _on_AnimatedSprite_animation_finished():
	queue_free()

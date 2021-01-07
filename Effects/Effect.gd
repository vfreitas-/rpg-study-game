extends AnimatedSprite

onready var animated_sprite = $AnimatedSprite

func _ready():
	self.connect("animation_finished", self, "_on_animation_end")
	frame = 0
	play("Animate")

func _on_animation_end():
	queue_free()

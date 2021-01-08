extends AnimatedSprite

func _ready():
	var _connected = self.connect("animation_finished", self, "_on_animation_end")
	frame = 0
	play("Animate")

func _on_animation_end():
	queue_free()

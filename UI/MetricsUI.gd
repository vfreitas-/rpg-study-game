extends Control

func _process(_delta):
	$FPS.text = str("FPS: ",(Engine.get_frames_per_second()))

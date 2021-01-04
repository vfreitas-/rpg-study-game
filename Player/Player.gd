extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

var velocity = Vector2.ZERO

onready var movingAnimationPlayer = $MovingAnimation
onready var movingAnimationTree = $MovingAnimationTree
# pega os valores do State Machine da animation tree
onready var movingAnimationState = movingAnimationTree.get("parameters/playback")

func _ready():
	var input_vector = Vector2.DOWN
	movingAnimationTree.set("parameters/Idle/blend_position", input_vector)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normaliza os vetores diagonais para terem o mesmo "tamanho" dos horizontais/verticais
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		# seta os valores para Idle e Run da animation tree
		movingAnimationTree.set("parameters/Idle/blend_position", input_vector)
		movingAnimationTree.set("parameters/Run/blend_position", input_vector)
		# define com o state de run
		movingAnimationState.travel("Run")
		# Se move na até o valor X, baseado no valor Y
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		movingAnimationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)

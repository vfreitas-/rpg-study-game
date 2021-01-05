extends KinematicBody2D

const ACCELERATION = 500
const MAX_SPEED = 80
const FRICTION = 500

enum State {
	ATTACK,
	MOVE,
	ROLL
}

var state = State.MOVE
var velocity = Vector2.ZERO

onready var animationTree = $AnimationTree
# pega os valores do State Machine da animation tree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true
	
	var input_vector = Vector2.DOWN
	animationTree.set("parameters/Idle/blend_position", input_vector)

# _physics_process: quando acessamos alguma propriedade que tenha a ver com o posicionamento
# do KitematicBody por exemplo, com a fisica dele
# _process: quando não acessamos esses valores e temos uma função mais pura com valores próprios
func _process(delta):
	match state:
		State.ATTACK:
			handle_attack(delta)
		
		State.MOVE:
			handle_move(delta)
			
		State.ROLL:
			handle_roll(delta)
	
func handle_move(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# Normaliza os vetores diagonais para terem o mesmo "tamanho" dos horizontais/verticais
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		# seta os valores para Idle e Run da animation tree
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		# define com o state de run
		animationState.travel("Run")
		# Se move na até o valor X, baseado no valor Y
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("attack"):
		state = State.ATTACK
		
func handle_attack(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func handle_roll(delta):
	print("Roll!")
	
func handle_attack_animation_end():
	state = State.MOVE

extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var FRICTION = 500
export var ROLL_SPEED = 110

enum State {
	ATTACK,
	MOVE,
	ROLL
}

var state = State.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationTree = $AnimationTree
# pega os valores do State Machine da animation tree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	animationTree.active = true
	
	swordHitbox.knockback_vector = roll_vector
	
	var input_vector = Vector2.DOWN
	animationTree.set("parameters/Idle/blend_position", input_vector)

# _physics_process: quando acessamos alguma propriedade que tenha a ver com o posicionamento
# do KitematicBody por exemplo, com a fisica dele
# _process: quando não acessamos esses valores e temos uma função mais pura com valores próprios
func _physics_process(delta):
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
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		# seta os valores para Idle e Run da animation tree
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		# define com o state de run
		animationState.travel("Run")
		# Se move na até o valor X, baseado no valor Y
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = State.ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = State.ATTACK
		
func handle_attack(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func handle_roll(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func move():
	velocity = move_and_slide(velocity)
	
# Callbacks and Signals
func handle_roll_animation_end():
	velocity = velocity * 0.8
	state = State.MOVE
	
func handle_attack_animation_end():
	state = State.MOVE

extends KinematicBody2D

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200

enum State {
	IDLE,
	CHASE,
	ATTACK,
	WANDER
}

var velocity = Vector2.ZERO

var state = State.IDLE

onready var playerDetectionZone = $PlayerDetectionZone
onready var animationTree = $AnimationTree
# pega os valores do State Machine da animation tree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true
	
	var input_vector = Vector2.DOWN
	animationTree.set("parameters/Idle/blend_position", input_vector)
	
func _physics_process(delta):
	animationTree.set("parameters/Attack/blend_position", Vector2.DOWN)
	
	match state:
		State.IDLE:
			handle_idle(delta)
		
		State.CHASE:
			handle_chase(delta)
			
		State.ATACK:
			handle_attack(delta)
			
	velocity = move_and_slide(velocity)
			
func handle_idle(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	# TODO: arrumar o vetor passado pro animation tree
	animationTree.set("parameters/Idle/blend_position", Vector2.ZERO)
	animationState.travel("Idle")
	seek_player()
	
func handle_chase(delta):
	var player = playerDetectionZone.player
	if playerDetectionZone.can_see_player():
		var direction = global_position.direction_to(player.global_position)
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		animationTree.set("parameters/Walk/blend_position", direction)
		animationState.travel("Walk")
	else:
		state = State.IDLE
	
func handle_attack(detla):
	animationState.travel("Attack")
	pass
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = State.CHASE

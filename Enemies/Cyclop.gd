extends KinematicBody2D

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200
export var RATE_ATTACK = 0.3

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum State {
	IDLE,
	CHASE,
	ATTACK,
	WANDER
}

var velocity = Vector2.ZERO
var last_direction = Vector2.ZERO
var state = State.IDLE
var can_attack = true

onready var playerDetectionZone = $PlayerDetectionZone
onready var hitboxDetectionZone = $HitboxDetectionZone
onready var hurtBox = $Hurtbox
onready var animationTree = $AnimationTree
onready var attackTimer = $AttackTimer
onready var stats = $Stats
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
			
		State.ATTACK:
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
		last_direction = direction
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		animationTree.set("parameters/Walk/blend_position", direction)
		animationState.travel("Walk")
	else:
		state = State.IDLE
	
func handle_attack(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if can_attack:
		animationTree.set("parameters/Attack/blend_position", last_direction)
		animationState.travel("Attack")
		can_attack = false
	else:
		#hitboxDetectionZone.toggleMonitoring(true)
		#seek_player()
		pass
	
func seek_player():
	if playerDetectionZone.can_see_player():
		state = State.CHASE
	else:
		state = State.IDLE

# Callbacks and Signals
func _on_attack_animation_end():
	print('callback')
	seek_player()
	hitboxDetectionZone.toggleMonitoring(true)
	attackTimer.start(RATE_ATTACK)

func _on_HitboxDetectionZone_body_entered(_body):
	hitboxDetectionZone.toggleMonitoring(false)
	state = State.ATTACK

func _on_AttackTimer_timeout():
	can_attack = true

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtBox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.position = position

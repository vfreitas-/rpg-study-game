extends KinematicBody2D

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum State {
	IDLE,
	WANDER,
	CHASE
}

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

var state = State.IDLE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtBox = $Hurtbox
onready var softCollision = $SoftCollision

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		State.WANDER:
			pass
		State.CHASE:
			var player = playerDetectionZone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
			else:
				state = State.IDLE
			sprite.flip_h = velocity.x < 0
	
	# Caso eu queira lidar com a colisão através de uma lógica própria
	# Temos também a opção de colocar em Collision a Mask do Bat como Enemy
	# Dizendo que o collision do bat pode colidir com outros Enemies
	# Porém visualmente não fica tao robusto quanto essa solução de afastamento
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = State.CHASE

# Callbacks and Signals
func _on_Hurtbox_area_entered(area):
	print(area)
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtBox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	#enemyDeathEffect.global_position = global_position
	enemyDeathEffect.position = position

extends KinematicBody2D
var velocity =Vector2.ZERO
var state=CHASE
var knockback=Vector2.ZERO
onready var stats=$Stats
onready var playerDetectionZone=$PlayerDetectionZone
onready var sprite=$AnimatedSprite
onready var animationPlayer=$AnimationPlayer
const EnemyDeathEffect=preload("res://Effects/EnemyDeathEffect.tscn")
export var MAX_SPEED=50
export var ACCELERATION=300
export var FRICTION=200
export var WANDER_TARGET_RANGE=4
onready var hurtbox=$Hurtbox
onready var softCollision=$SoftCollision
onready var wander_controller=$WanderController


enum{
	IDLE,
	WANDER,
	CHASE
}
func _ready():
	state=pick_random_state([IDLE,WANDER])

func _physics_process(delta):
	knockback=knockback.move_toward(Vector2.ZERO,FRICTION*delta)
	knockback=move_and_slide(knockback)
	match state:
		IDLE:
			velocity=velocity.move_toward(Vector2.ZERO,FRICTION*delta)
			seek_player()
			if wander_controller.get_time_left()==0:
				update_wander()
		WANDER:
			if wander_controller.get_time_left()==0:
				update_wander()
			accelerate_towards_point(wander_controller.target_position,delta)
			if global_position.distance_to(wander_controller.target_position)<= WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			var player=playerDetectionZone.player
			if player!=null:
				accelerate_towards_point(player.global_position,delta)

			else:
				state=IDLE
	if softCollision.is_colliding():
		velocity+=softCollision.get_push_vector()*delta*400
	velocity=move_and_slide(velocity)
	

func seek_player():
	if playerDetectionZone.can_see_player():
		state=CHASE	

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()	

func accelerate_towards_point(point,delta):
	var direction=global_position.direction_to(point)
	velocity=velocity.move_toward(MAX_SPEED*direction,ACCELERATION*delta)
	sprite.flip_h=velocity.x<0

func update_wander():
	state=pick_random_state([IDLE,WANDER])
	wander_controller.start_wander_timer(rand_range(1,3))
	
func _on_Hurtbox_area_entered(area):
	stats.health-=area.damage
	knockback=area.knockback_vector*100
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect=EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position=global_position


func _on_Hurtbox_invincibility_started():
	animationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	animationPlayer.play("Stop")

extends KinematicBody2D
var velocity=Vector2.ZERO
const acceleration=500
const MAX_SPEED=80
const friction=500
const roll_speed=120
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
onready var animationPlayer=$AnimationPlayer
onready var animationTree=$AnimationTree
onready var animationState=$AnimationTree.get("parameters/playback")
onready var swordHitbox=$HitboxPivot/SwordHitbox
onready var Hurtbox=$Hurtbox
onready var BlinkAnimationPlayer=$BlinkAnimationPlayer
var stats=PlayerStats
enum{
	MOVE,
	ROLL,
	ATTACK
}
var state=MOVE
var roll_vector=Vector2.DOWN

func _ready():
	randomize()
	stats.connect("no_health",self,"queue_free")
	animationTree.active=true
	swordHitbox.knockback_vector=roll_vector
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
		
	
	

func move_state(delta):
	"""The main function for movement of the character and uses 
	the animation tree to play 
	the necessary animations for the character"""
	
	
	
	
	var input_vector=Vector2.ZERO
	input_vector.x=Input.get_action_strength("ui_right") -Input.get_action_strength("ui_left")
	input_vector.y=Input.get_action_strength("ui_down")- Input.get_action_strength("ui_up")
	input_vector=input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector=input_vector
		swordHitbox.knockback_vector=input_vector
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		velocity=velocity.move_toward(input_vector*MAX_SPEED,acceleration*delta)
	else:
		animationState.travel("Idle")
		velocity=velocity.move_toward(Vector2.ZERO,friction*delta)
	move()
	if Input.is_action_just_pressed("roll"):
		state=ROLL
	
	if Input.is_action_just_pressed("attack"):
		state=ATTACK


func roll_state():
	velocity=roll_vector*roll_speed
	animationState.travel("Roll")
	move()
func attack_state():
	velocity=Vector2.ZERO
	animationState.travel("Attack")
func move():
	velocity=move_and_slide(velocity)	
func attack_animation_finished():
	state=MOVE
func roll_animation_finished():
	velocity=velocity*0.8
	state=MOVE


func _on_Hurtbox_area_entered(area):
	stats.health-=area.damage
	Hurtbox.start_invincibility(0.6)
	Hurtbox.create_hit_effect()
	var playerHurtSounds=PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSounds)


func _on_Hurtbox_invincibility_ended():
	BlinkAnimationPlayer.play("Stop")


func _on_Hurtbox_invincibility_started():
	BlinkAnimationPlayer.play("Start")

extends CharacterBody2D

@onready var furniture_map = get_node("../Map_1/Furniture")
@onready var wander_timer = $WanderTimer  
@onready var increase_speed_timer : Timer = $IncreaseSpeed
@onready var ANIMATION : AnimatedSprite2D = $AnimatedSprite2D
signal kill_registered(count : int)

## enemy speeds :
var WAN_SPEED = 30
var wander_velocity = Vector2.ZERO
var FOLLOW_SPEED = 38
var MAX_FOLLOW_SPEED = 46
@export var increase_speed_in = 3

## enemy conditions : 
var HEALTH = 100
var FOLLOW_PLY = false
var player_ref = null
var current_des_zone

##Furniture Variables :
var IN_RANGE_FUR = false  
var IS_ATTACKING_FUR = false

func _ready():
	add_to_group("Enemy")
	randomize()
	wander_timer.connect("timeout", Callable(self, "_pick_new_wander_direction"))
	_pick_new_wander_direction() 
	call_deferred("_connect_to_zones")
	increase_speed_timer.wait_time = 3
	increase_speed_timer.one_shot = false
	increase_speed_timer.timeout.connect(_on_increase_speed_timeout)

func _physics_process(delta):
	if FOLLOW_PLY and player_ref and !IN_RANGE_FUR:
		var direction = (player_ref.global_position - global_position).normalized()
		set_velocity(direction * FOLLOW_SPEED)
		move_and_slide()
	elif(IN_RANGE_FUR and !FOLLOW_PLY):
		IS_ATTACKING_FUR = true
	else:
		set_velocity(wander_velocity)
		move_and_slide()
		ANIMATION.play("default")

func _pick_new_wander_direction():
	var velocity = Vector2.ZERO
	velocity.x = 1 if randf() > 0.5 else -1
	velocity.y = 1 if randf() > 0.5 else -1
	wander_velocity = velocity.normalized() * WAN_SPEED

func _on_increase_speed_timeout() -> void:
	if FOLLOW_PLY:
		FOLLOW_SPEED = min(FOLLOW_SPEED + increase_speed_in, MAX_FOLLOW_SPEED)
		#print("Speed increased to: ", FOLLOW_SPEED)

func _update_status_destroy(body: Node2D, is_attacked: bool):
	if body == self:
		IN_RANGE_FUR = is_attacked


func _on_Detect_Sphere_body_entered(body):
	if body.is_in_group("Player"):
		player_ref = body
		FOLLOW_PLY = true
		increase_speed_timer.start()
	if body.is_in_group("Destroy_Zones"):
		var p = body.name
		print("Enemy is at the body name",p)

func _on_Detect_Sphere_body_exited(body):
	if body.is_in_group("Player"):
		FOLLOW_PLY = false
		player_ref = null
		FOLLOW_SPEED = 38
		increase_speed_timer.stop()

func _connect_to_zones():
	var zones = get_tree().get_nodes_in_group("Destroy_Zones")
	for des_zn in zones:
		des_zn.broadcast_furniture_status.connect(_update_status_destroy)

func _on_health_body_entered(body: Node2D) -> void:
	var count : int = 1
	if body.is_in_group("Bullets"):
		HEALTH-=50
		body.queue_free()
		if(HEALTH<10):
			body.queue_free()
			Global.register_kill()
			queue_free()

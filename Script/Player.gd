extends CharacterBody2D

var bullet_assest = preload("res://Scene/Guns/Bullet.tscn") 
@onready var aim_assest : AnimatedSprite2D =  $Aim_Sprite
@onready var Ammo_Sprite : AnimatedSprite2D = $Ammo_Sprite
@onready var HLT_SPRITES: AnimatedSprite2D = $Health_Sprite
@onready var HLT_TIME : Timer = $HEALTH_Timer
@onready var interactive_UI : CanvasLayer = $Interactive_UI

var PLY_HLT = 3
var MAX_HLT = 5
@export var HUNGER_TIMER = 60
var CAN_FIRE = true
var AIM_DISTANCE = 50
@export var AMMO = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Player")
	Global.set_player_refference(self) 
	HLT_TIME.wait_time = HUNGER_TIMER
	HLT_TIME.one_shot = true
	HLT_TIME.start()
	HLT_TIME.timeout.connect(_on_health_timer_timeout)
	update_health_sprite()
	
func _physics_process(delta):
	player_movement()
	aim_weapons()
	
	
func player_movement():
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("forward"):
		velocity.y -=1
	if Input.is_action_pressed("back"):
		velocity.y +=1
	if Input.is_action_pressed("left"):
		velocity.x -=1
	if Input.is_action_pressed("right"):
		velocity.x +=1
	if Input.is_action_pressed("fire") and CAN_FIRE:
		fire()
	velocity = velocity.normalized() * 50
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	
func fire():
	if AMMO>0:
		CAN_FIRE = false
		var direction = (get_global_mouse_position() - global_position).normalized()
		var bullet = bullet_assest.instantiate()
		
		get_tree().current_scene.add_child(bullet)
		fire_animation()
		bullet.global_position = global_position + direction * 10
		bullet.rotation = direction.angle()
		if bullet.has_method("set_direction"):
			bullet.set_direction(direction)
		
		await get_tree().create_timer(1).timeout
		CAN_FIRE = true

## AMMO ------------------------
func fire_animation():
	AMMO-=1
	var frame_count = Ammo_Sprite.sprite_frames.get_frame_count("Ammo_Stock")
	var ratio = float(AMMO) / 6
	var frame_index = int((1.0 - ratio) * (frame_count - 1))
	Ammo_Sprite.frame = clamp(frame_index, 0, frame_count - 1)
	
func aim_weapons():
	var direction = (get_global_mouse_position() - global_position).normalized()
	aim_assest.global_position = global_position + direction * AIM_DISTANCE

## HEALTH ------------------------
func set_health(value: int):
	PLY_HLT = clamp(value, 0, MAX_HLT)
	update_health_sprite()
	if PLY_HLT == 0:
		die()

func update_health_sprite():
	var frame_count = HLT_SPRITES.sprite_frames.get_frame_count("Health")
	var ratio = float(PLY_HLT) / MAX_HLT
	var frame_index = int((1.0 - ratio) * (frame_count - 1))
	HLT_SPRITES.frame = clamp(frame_index, 0, frame_count - 1)

func die():
	print("PLAYER DIED OF HUNGER")
	queue_free()

func _on_health_timer_timeout():
	set_health(PLY_HLT - 1)
	HLT_TIME.start()
	

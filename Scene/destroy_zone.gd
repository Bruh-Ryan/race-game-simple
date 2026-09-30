extends Area2D

var HEALTH = 100

signal broadcast_furniture_status(is_attacked: bool, name_obj : String)
signal broadcast_player_entry(is_allowed: bool)
@onready var SHOW_FURNITURE_HEALTH : AnimatedSprite2D = $"../Health"
@onready var DAMAGE_TIME : Timer = $"../Timer"  # placed in editor, wait_time=5, one_shot=false
@onready var ALLOWED : = $"../ALLOW"

func _ready() -> void:
	add_to_group("Destroy_Zones")
	SHOW_FURNITURE_HEALTH.hide()
	body_entered.connect(_on_body_entered_enemy)
	body_exited.connect(_on_body_exited)
	DAMAGE_TIME.timeout.connect(_on_damage_timer_timeout)

func _on_body_entered_enemy(body: Node2D) -> void:
	if body.is_in_group("Enemy") and HEALTH != 0:
		broadcast_furniture_status.emit(body, true)
		SHOW_FURNITURE_HEALTH.show()
		DAMAGE_TIME.start()
	elif body.is_in_group("Player"):
		broadcast_furniture_status.emit(body, true)
	# consider removing the confusing else-branch entirely (see below)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		broadcast_furniture_status.emit(body, false)
		SHOW_FURNITURE_HEALTH.hide()
		DAMAGE_TIME.stop()
	elif body.is_in_group("Player"):
		broadcast_furniture_status.emit(body, false)
	if HEALTH!=0:
		ALLOWED.frame = 0
	ALLOWED.frame = 1
	
func _on_damage_timer_timeout() -> void:
	HEALTH -= 20
	HEALTH = clamp(HEALTH, 0, 100)
	_update_health_sprite()
	if HEALTH <= 0:
		# no single "body" here since this is time-based, not a body event
		DAMAGE_TIME.stop()

func _update_health_sprite() -> void:
	var frame_count = SHOW_FURNITURE_HEALTH.sprite_frames.get_frame_count("Health")
	var ratio = float(HEALTH) / 100.0
	var frame_index = int((1.0 - ratio) * (frame_count - 1))
	SHOW_FURNITURE_HEALTH.frame = clamp(frame_index, 0, frame_count - 1)

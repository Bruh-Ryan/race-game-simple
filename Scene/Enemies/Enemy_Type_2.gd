extends CharacterBody2D

@onready var wander_timer = $WanderTimer
@onready var animation = $Type_2
var current_zone 

var SPEED = 10
var ENEMY_SPEED = 10
var FOLLOW_PLY = false
var PLY_REF = null
var attack_player = false

var is_jumping = false
var jump_target = Vector2.ZERO
var jump_duration = 0.8
var jump_height = 20

var HEALTH = 100

func _ready():
	add_to_group("Enemy")
	$Impact_Zone.body_entered.connect(_on_impact_zone_body_entered)
	for zone in get_tree().get_nodes_in_group("Zone"):
		zone.broadcast_player_zone.connect(_on_zone_update)

	
func _physics_process(delta: float) -> void:
	if FOLLOW_PLY and PLY_REF and not is_jumping and attack_player:
		start_jump(PLY_REF.global_position)
		
	move_and_slide()

func _on_zone_update(zone_name: String, is_inside: bool):
	if zone_name == current_zone:
		attack_player = true
	if current_zone == null:
		pass
	
func start_jump(target_pos: Vector2):
	is_jumping = true
	
	jump_target = target_pos
	var start_pos = global_position
	var tween = create_tween()
	tween.set_parallel(true)

	# horizontal movement: straight line from start to target
	tween.tween_property(self, "global_position", jump_target, jump_duration)

	# fake vertical arc using a Sprite2D/AnimatedSprite2D offset, not position itself
	tween.tween_method(_update_jump_arc, 0.0, 1.0, jump_duration)

	tween.chain().tween_callback(_on_jump_finished)
	
func _update_jump_arc(t: float) -> void:
	# parabola: 0 at t=0, peak at t=0.5, 0 at t=1
	var arc = -4 * jump_height * (t - 0.5) * (t - 0.5) + jump_height
	animation.position.y = -arc  # negative = visually "up"
	
func _on_jump_finished() -> void:
	animation.position.y = 0
	is_jumping = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.is_in_group("Player"):
		FOLLOW_PLY = true
		PLY_REF = body
		animation.play("jump")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		FOLLOW_PLY = false
		PLY_REF = null
		animation.play("default")


func _on_impact_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Bullets"):
		HEALTH -= 50
		body.queue_free()
		if HEALTH < 10:
			Global.register_kill()
			queue_free()

func _on_range_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "Zone1":
		current_zone = area.name

func _on_range_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == "Zone1":
		current_zone = ""

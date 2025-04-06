extends Area2D

@onready var sprite = $Sprite2D

var hit_player = false
var is_going_right = true
@export var SPEED = 300
@onready var hit_sfx = $HitSFX
@onready var collision_shape = $CollisionShape2D

func _ready():
	sprite.flip_h = not is_going_right

func _physics_process(delta: float) -> void:
	if is_going_right:
		position += Vector2.RIGHT * SPEED * delta
	else:
		position += Vector2.LEFT * SPEED * delta

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if collision_shape.disabled:
		return
	if body.name == "TileMapLayer":
		hit_sfx.playing = true
		$Sprite2D.visible = false
		collision_shape.disabled = true
	elif body.collision_layer == 1 and hit_player:
		body.hit()
		collision_shape.disabled = true
		$Sprite2D.visible = false
		hit_sfx.playing = true
	elif body.collision_layer == 2 and not hit_player:
		body.hit()
		collision_shape.disabled = true
		$Sprite2D.visible = false
		hit_sfx.playing = true


func _on_area_entered(area: Area2D) -> void:
	if area.collision_layer == 8 and hit_player != area.hit_player:
		hit_sfx.playing = true
		collision_shape.disabled = true
		$Sprite2D.visible = false


func _on_hit_sfx_finished() -> void:
	queue_free()

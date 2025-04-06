extends CharacterBody2D

@export var SPEED = 200
@export var CHARGE_SPEED = 500
@export var ACCELERATION = 30
@export var health = 2

@onready var player = $"../Player"
@onready var timer = $Timer
@onready var sprite = $AnimatedSprite2D
@onready var blood_particles = $BloodParticles
@onready var charge_sfx = $ChargeSFX
@onready var hurt_sfx = $HurtSFX

var is_attacking = false
var direction = Vector2()

func _ready():
	direction.x = 1
	sprite.flip_h = true
	set_direction()
	timer.start(randf_range(2.5, 3.5))

func _physics_process(_delta):
	if not is_attacking:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.y = move_toward(velocity.y, direction.y * SPEED, ACCELERATION)
	move_and_slide()

func set_direction():
	direction.x *= -0.1
	sprite.flip_h = not sprite.flip_h
	direction.y = randf_range(0.5, 0.9)
	if randi_range(0, 1):
		direction.y *= -1

func _on_area_2d_body_entered(body):
	if body.name == "TileMapLayer":
		sprite.play("idle")
		is_attacking = false
		set_direction()
		timer.start()
	elif body.collision_layer == 1:
		body.hit()


func hit():
	health -= 1
	blood_particles.emitting = true
	if health <= 0:
		sprite.visible = false
		$DeathSFX.playing = true
	else:
		hurt_sfx.playing = true

func _on_timer_timeout() -> void:
	charge_sfx.playing = true
	sprite.play("attack")
	if direction.x > 0:
		direction.x = 1
	else:
		direction.x = -1
	direction.y = 0
	velocity.x = direction.x * CHARGE_SPEED
	velocity.y = 0
	is_attacking = true

func _on_wall_check_y_body_entered(_body: Node2D) -> void:
	direction.y *= -1


func _on_blood_particles_finished() -> void:
	if health <= 0:
		queue_free()

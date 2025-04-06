extends CharacterBody2D

@export var SPEED = 150
@export var ACCELERATION = 10
@export var health = 2

@onready var projectile = load("res://scenes/projectile.tscn")
@onready var player = $"../Player"
@onready var timer = $Timer
@onready var cooldownTimer = $CooldownTimer
@onready var parent = get_parent()
@onready var sprite = $AnimatedSprite2D
@onready var blood_particles = $BloodParticles
@onready var hurt_sfx = $HurtSFX
@onready var death_sfx = $DeathSFX

var is_attacking = false
var direction = Vector2()

func _ready():
	set_direction()
	timer.start(randf_range(2.5, 3.5))

func _physics_process(_delta):
	if not is_attacking:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.y = move_toward(velocity.y, direction.y * SPEED, ACCELERATION)
	move_and_slide()

func set_direction():
	if position > player.position:
		direction.x = randf_range(-0.1, -0.5)
		sprite.flip_h = true
	else:
		direction.x = randf_range(0.1, 0.5)
		sprite.flip_h = false
	direction.y = randf_range(-0.5, 0.5)

func _on_area_2d_body_entered(body):
	if body.collision_layer == 1:
		body.hit()

func hit():
	blood_particles.emitting = true
	health -= 1
	if health <= 0:
		death_sfx.playing = true
		sprite.visible = false
	else:
		hurt_sfx.playing = true

func _on_timer_timeout() -> void:
	cooldownTimer.start()
	is_attacking = true
	var instance = projectile.instantiate()
	instance.position = position
	instance.position.y -= 6.5
	instance.hit_player = true
	instance.is_going_right = direction.x > 0
	parent.add_child.call_deferred(instance)
	velocity = Vector2.ZERO

func _on_wall_check_y_body_entered(_body: Node2D) -> void:
	direction.y *= -1

func _on_cooldown_timer_timeout() -> void:
	is_attacking = false
	set_direction()
	timer.start()


func _on_blood_particles_finished() -> void:
	if health <= 0:
		queue_free()


func _on_death_sfx_finished() -> void:
	queue_free()

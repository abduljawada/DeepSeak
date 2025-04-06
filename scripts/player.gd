extends CharacterBody2D

@onready var parent = get_parent()
@onready var projectile = load("res://scenes/projectile.tscn")
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = get_node("../CanvasLayer/HUD/HealthBar")
@onready var end_screen = get_node("../CanvasLayer/HUD/EndScreen")
@onready var lose_text = get_node("../CanvasLayer/HUD/LoseText")
@onready var blood_particles = $BloodParticles
@onready var o2_sfx = $O2SFX
@onready var lose_sfx = $LoseSFX
@onready var hurt_sfx = $HurtSFX

@export var SPEED = 200
@export var ACCELERATION = 50

var is_facing_right = true
var can_shoot = true

var health = 100

var is_alive = true

func _ready():
	randomize()
	health_bar.max_value = health
	Engine.time_scale = 1

func _process(delta):
	if is_alive:
		if Input.is_action_just_pressed("action") and can_shoot:
			can_shoot = false
			shoot()
		health -= delta
		health_bar.value = health
		if health <= 0:
			end_screen.visible = true
			lose_text.visible = true
			is_alive = false
			get_node("../ReloadTimer").start()
			lose_sfx.playing = true
			Engine.time_scale = 0.25

func _physics_process(_delta):
	if not is_alive:
		return
	var direction = Input.get_vector("left","right","up","down")
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCELERATION)
		velocity.y = move_toward(velocity.y, direction.y * SPEED, ACCELERATION)
		if direction.x != 0:
			is_facing_right = direction.x > 0
			sprite.flip_h = not is_facing_right
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
		velocity.y = move_toward(velocity.y, 0, ACCELERATION)
	move_and_slide()

func shoot():
	var instance = projectile.instantiate()
	instance.position = position
	instance.position.y -= 6.5
	instance.is_going_right = is_facing_right
	parent.add_child.call_deferred(instance)

func _on_timer_timeout() -> void:
	can_shoot = true

func hit():
	health -= 5
	blood_particles.emitting = true
	if health >= 0:
		hurt_sfx.playing = true

func breathe():
	health += 10
	o2_sfx.playing = true

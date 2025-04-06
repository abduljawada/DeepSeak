extends Node

@onready var o2 = load("res://scenes/o_2.tscn")
@onready var parent = get_parent()
@onready var timer = $Timer
@onready var end_screen = get_node("../CanvasLayer/HUD/EndScreen")
@onready var win_text = get_node("../CanvasLayer/HUD/WinText")
@export var next_scene_path = "res://scenes/level_2.tscn"
@onready var pufferfish = load("res://scenes/pufferfish.tscn")
@onready var puffer_timer = $PufferTimer
@export var spawn_puffer = true
@export var min_puffer_spawn_time = 5
@export var max_puffer_spawn_time = 10
@onready var win_sfx = $WinSFX
@onready var noise1_sfx = $Noise1
@onready var noise2_sfx = $Noise2
@onready var noise3_sfx = $Noise3
@onready var noise4_sfx = $Noise4

var noise_array

var started_win_timer = false

func _ready() -> void:
	noise_array = [noise1_sfx, noise2_sfx, noise3_sfx, noise4_sfx]
	start_timer()
	if spawn_puffer:
		puffer_timer.start(randf_range(min_puffer_spawn_time, max_puffer_spawn_time))

func _process(delta: float) -> void:
	if get_tree().get_nodes_in_group("Enemies").is_empty() and not started_win_timer:
		end_screen.visible = true
		win_text.visible = true
		get_node("../WinTimer").start()
		started_win_timer = true
		win_sfx.playing = true
		Engine.time_scale = 0.25

func _on_timer_timeout() -> void:
	var instance = o2.instantiate()
	instance.position = Vector2(randf_range(-120, 120), randf_range(-44, 54))
	parent.add_child.call_deferred(instance)
	start_timer()

func start_timer():
	timer.start(randf_range(20, 35))


func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_win_timer_timeout() -> void:
	get_tree().change_scene_to_file(next_scene_path)


func _on_puffer_timer_timeout() -> void:
	var instance = pufferfish.instantiate()
	instance.position = Vector2(120, randf_range(-44, 54))
	if randi_range(0, 1):
		instance.position.x *= -1
	parent.add_child.call_deferred(instance)
	puffer_timer.start(randf_range(min_puffer_spawn_time, max_puffer_spawn_time))


func _on_noise_timer_timeout() -> void:
	noise_array.pick_random().playing = true

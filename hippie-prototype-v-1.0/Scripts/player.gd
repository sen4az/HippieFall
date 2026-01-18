extends CharacterBody3D

@export var max_speed_x: float = 30.0
@export var max_speed_z: float = 30.0
@export var fall_speed_start: float = 20.0
@export var fall_speed_max: float = 65.0
@export var fall_speed_increment: float = .7
@export var lerp_factor: float = 10.0
@export var touch_sensitivity: float = 10.0

var is_alive: bool = true
signal died

var touch_delta: Vector2 = Vector2.ZERO
var is_touching: bool = false
var current_fall_speed: float

func _ready() -> void:
	current_fall_speed = fall_speed_start
	
	 # Connect the hitbox signal (assuming the Area3D is named "HitBox" in the scene)
	$HitBox.connect("body_entered", Callable(self, "_on_body_entered"))

	

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		touch_delta = event.relative * touch_sensitivity
	elif event is InputEventScreenTouch:
		is_touching = event.pressed
		touch_delta = Vector2.ZERO

func _physics_process(delta: float) -> void:
	current_fall_speed = clamp(current_fall_speed + fall_speed_increment * delta, fall_speed_start, fall_speed_max)
	velocity.y = -current_fall_speed

	var ix: float = 0.0
	var iz: float = 0.0
	if is_touching:
		ix = touch_delta.x / 100.0
		iz = touch_delta.y / 100.0
	else:
		ix = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		iz = -(Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"))

	var tx: float = ix * max_speed_x
	var tz: float = iz * max_speed_z

	var t: float = clamp(lerp_factor * delta, 0.0, 1.0)
	velocity.x = lerp(velocity.x, tx, t)
	velocity.z = lerp(velocity.z, tz, t)

	move_and_slide()


func _on_body_entered(body) -> void:
	if body == get_parent():  # Ignore the player itself
		return
	if is_alive:
		print("Game over triggered by: ", body.name)  # Optional debug
		is_alive = false
		died.emit()

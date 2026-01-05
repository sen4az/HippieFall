extends CharacterBody3D

# Movement Speeds
@export var max_speed_x: float = 25.0
@export var max_speed_z: float = 25.0

# Dynamic Falling Speed
@export var fall_speed_start: float = 10.0  # Initial falling speed
@export var fall_speed_max: float = 50.0  # Maximum falling speed
@export var fall_speed_increment: float = 1  # Speed increment per second

# Smoothing for movement (lerp)
@export var lerp_factor: float = 10.0  # Controls smoothness; larger = faster transitions

# Touch Controls
@export var touch_sensitivity: float = 10.0  # Customize drag responsiveness for mobile
var touch_delta: Vector2 = Vector2.ZERO
var is_touching: bool = false

# Internal state
var current_fall_speed: float

func _ready():
	# Initialize current falling speed
	current_fall_speed = fall_speed_start

func _input(event):
	if event is InputEventScreenDrag:
		# Calculate swipe movement based on touch delta
		touch_delta = event.relative * touch_sensitivity
	elif event is InputEventScreenTouch:
		# Set touch state (pressed/released)
		is_touching = event.pressed
		touch_delta = Vector2.ZERO  # Reset delta when touch ends

func _physics_process(delta: float) -> void:
	# Dynamically increase falling speed over time, clamped to the maximum
	current_fall_speed = clamp(current_fall_speed + fall_speed_increment * delta, fall_speed_start, fall_speed_max)
	velocity.y = -current_fall_speed  # Apply dynamic falling speed

	# Get movement inputs (either touch-based or keyboard-based)
	var ix: float = 0.0
	var iz: float = 0.0
	if is_touching:
		# Use the drag-based input for mobisdsale devices
		ix = touch_delta.x / 100
		iz = touch_delta.y / 100  # Drags downward move positively along Z
	else:
		# Keyboard controls for PC
		ix = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		iz = -(Input.get_action_strength("move_forward") - Input.get_action_strength("move_back"))  # Reverse for +Z

	# Calculate target velocity (scaled by max speeds)
	var tx: float = ix * max_speed_x
	var tz: float = iz * max_speed_z

	# Smoothly interpolate to target velocity using lerp (frame-rate scaled for consistency)
	var t: float = clamp(lerp_factor * delta, 0.0, 1.0)
	velocity.x = lerp(velocity.x, tx, t)
	velocity.z = lerp(velocity.z, tz, t)

	# Apply 
	print(current_fall_speed)
	move_and_slide()

extends CharacterBody3D

# Speeds
@export var max_speed_x: float = 20.0
@export var max_speed_z: float = 20.0
@export var fall_speed: float = 8.0

# Smoothing (lerp)
@export var lerp_factor: float = 10.0   # larger = faster interpolation (try 4..20)

# Upgrades / debug
@export var speed_multiplier: float = 1.0
@export var debug: bool = true

func _physics_process(delta: float) -> void:
	# always fall down on Y
	velocity.y = -fall_speed

	# analog-friendly inputs (-1 .. +1)
	var ix: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var iz: float = Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")

	# targets (apply multiplier); forward -> -Z
	var tx: float = ix * max_speed_x * speed_multiplier
	var tz: float = -iz * max_speed_z * speed_multiplier

	# smooth velocity change toward target using lerp (frame-rate scaled)
	var t: float = clamp(lerp_factor * delta, 0.0, 1.0)
	velocity.x = lerp(velocity.x, tx, t)
	velocity.z = lerp(velocity.z, tz, t)

	if debug:
		print("vel:", velocity, "pos:", global_transform.origin)

	move_and_slide()

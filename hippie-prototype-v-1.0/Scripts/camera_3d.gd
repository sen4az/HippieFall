extends Camera3D

# Smoothing parameters
@export var smoothing_speed: float = 1.0 # Higher value = tighter follow
@export var offset: Vector3 = Vector3(0, 3.3, -0.5) # Default offset to position camera above and behind the player

# Tunnel boundary limits (adjust these to match your tunnel dimensions)
#@export var bounds_min: Vector3 = Vector3(-5, 0, -20)  # Example: lower limit
#@export var bounds_max: Vector3 = Vector3(5, 10, 20)   # Example: upper limit

# Reference to the player (export helps assigning in the Inspector)
@export var player: NodePath

# Internal cached position for stability
var target_position: Vector3

func _ready():
	if player == null:
		print("Error: Player node must be assigned!")
		return

	# Initialize tracking player position
	target_position = get_node(player).global_transform.origin

func _process(delta):
	var player_node = get_node(player)
	if not player_node:
		return

	# Determine target position in 3D space
	target_position = player_node.global_transform.origin + offset

	# Optional lag smoothing using `lerp` (linear interpolation between current and target positions)
	global_transform.origin = global_transform.origin.lerp(target_position, delta * smoothing_speed)

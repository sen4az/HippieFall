extends Camera3D

# Parameters for camera behavior
@export var smoothing_speed: float = 1.0 # Moderate smoothing for balance
@export var offset: Vector3 = Vector3(0, 3.5, -0.9) # Camera position above and slightly behind the player
@export var catch_up_threshold: float = 1.0 # Distance threshold for faster correction
@export var catch_up_factor: float = 0.1 # Catch-up strength for aggressive following

@export var player: NodePath # Reference to the player node (set in Inspector)

# Internal cached position for camera movement
var target_position: Vector3

func _ready():
	# Validate the player node
	if player == null or not has_node(player):
		print("Error: Player node not assigned!")
		set_process(false)
		return
	
	# Initialize target position
	var player_node = get_node(player)
	target_position = player_node.global_transform.origin

func _process(delta):
	# Retrieve the player node
	var player_node = get_node(player)
	if not player_node:
		print("Warning: Player node not found!")
		return

	# Calculate the desired target position based on the player's position and offset
	var desired_position = player_node.global_transform.origin + offset

	# Gradually smooth toward the desired position
	var movement_smoothness: float = 1.0 - exp(-smoothing_speed * delta)
	global_transform.origin = global_transform.origin.lerp(desired_position, movement_smoothness)

	# Aggressive catch-up logic if the camera lags too far behind
	if global_transform.origin.distance_to(desired_position) > catch_up_threshold:
		global_transform.origin = global_transform.origin.lerp(desired_position, catch_up_factor)

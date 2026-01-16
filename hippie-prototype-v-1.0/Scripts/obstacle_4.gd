extends Node3D

@export var path_radius: float = 5.0      # distance of the hole from center
@export var path_speed: float = 0.50       # cycles per second
@export var vertical_amp: float = 0.0     # set >0 for up/down wobble
@export var vertical_speed: float = 0.5   # wobble speed
@export var use_ping_pong: bool = false   # true = linear ping-pong; false = circular
@export var hole_node_path: NodePath  # subtractive child

var _t := 0.0
var _hole: CSGShape3D

func _ready() -> void:
	_hole = get_node_or_null(hole_node_path) as CSGShape3D
	if _hole:
		_hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	else:
		push_error("Hole node not found or not a CSGShape3D")

func _process(delta: float) -> void:
	if _hole == null:
		return
	_t += delta

	if use_ping_pong:
		# Linear left/right ping-pong on X (change axis if desired)s
		var phase := sin(_t * TAU * path_speed)  # -1..1
		_hole.position.x = phase * path_radius
		_hole.position.y = sin(_t * TAU * vertical_speed) * vertical_amp
	else:
		# Circular path
		var angle := TAU * path_speed * _t
		var x := cos(angle) * path_radius
		var z := sin(angle) * path_radius
		var y := sin(_t * TAU * vertical_speed) * vertical_amp
		_hole.position = Vector3(x, y, z)
